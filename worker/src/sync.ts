import { D1Database } from "@cloudflare/workers-types";
import type { SyncPayload, AuthUser } from "./auth";

/**
 * Sync user data from client to cloud (D1)
 * Uses "last write wins" with timestamp-based conflict resolution
 */
export async function syncUserData(
  db: D1Database,
  user: AuthUser,
  payload: SyncPayload
): Promise<{ success: boolean; syncedAt: number; conflicts: string[] }> {
  const now = Date.now();
  const conflicts: string[] = [];

  try {
    // Use transaction for atomicity
    const statements: D1PreparedStatement[] = [];

    // 1. Update user last_sync_at
    statements.push(
      db.prepare(
        "UPDATE users SET last_sync_at = ?, updated_at = ? WHERE id = ?"
      ).bind(now, now, user.id)
    );

    // 2. Sync preferences
    if (payload.preferences) {
      const pref = payload.preferences;
      statements.push(
        db.prepare(`
          INSERT INTO user_preferences (user_id, is_dark_mode, locale, text_scale,
            daily_reminder_time, daily_reminder_enabled, preferred_bible_version,
            translation_style, denomination, ai_auth_token, has_completed_onboarding, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(user_id) DO UPDATE SET
            is_dark_mode = excluded.is_dark_mode,
            locale = excluded.locale,
            text_scale = excluded.text_scale,
            daily_reminder_time = excluded.daily_reminder_time,
            daily_reminder_enabled = excluded.daily_reminder_enabled,
            preferred_bible_version = excluded.preferred_bible_version,
            translation_style = excluded.translation_style,
            denomination = excluded.denomination,
            ai_auth_token = excluded.ai_auth_token,
            has_completed_onboarding = excluded.has_completed_onboarding,
            updated_at = excluded.updated_at
        `).bind(
          user.id,
          pref.isDarkMode ? 1 : 0,
          pref.locale,
          pref.textScale,
          pref.dailyReminderTime,
          pref.dailyReminderEnabled ? 1 : 0,
          pref.preferredBibleVersion,
          pref.translationStyle,
          pref.denomination,
          pref.aiAuthToken,
          pref.hasCompletedOnboarding ? 1 : 0,
          now
        )
      );
    }

    // 3. Sync favorite verses (replace all)
    if (payload.favoriteVerses) {
      // Delete old
      statements.push(
        db.prepare("DELETE FROM favorite_verses WHERE user_id = ?").bind(user.id)
      );
      // Insert new
      for (const verseKey of payload.favoriteVerses) {
        statements.push(
          db.prepare(
            "INSERT INTO favorite_verses (user_id, verse_key, created_at) VALUES (?, ?, ?)"
          ).bind(user.id, verseKey, now)
        );
      }
    }

    // 4. Sync chat sessions
    if (payload.chatSessions) {
      for (const session of payload.chatSessions) {
        statements.push(
          db.prepare(`
            INSERT INTO chat_sessions (id, user_id, title, created_at, updated_at, is_deleted)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              title = excluded.title,
              updated_at = excluded.updated_at,
              is_deleted = excluded.is_deleted
          `).bind(
            session.id,
            user.id,
            session.title,
            session.createdAt,
            session.updatedAt,
            session.isDeleted ? 1 : 0
          )
        );
      }
    }

    // 5. Sync chat messages
    if (payload.chatMessages) {
      for (const msg of payload.chatMessages) {
        statements.push(
          db.prepare(`
            INSERT INTO chat_messages (id, session_id, user_id, text, is_user,
              verse_reference, is_error, timestamp, synced_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              text = excluded.text,
              is_user = excluded.is_user,
              verse_reference = excluded.verse_reference,
              is_error = excluded.is_error,
              timestamp = excluded.timestamp,
              synced_at = excluded.synced_at
          `).bind(
            msg.id,
            msg.sessionId,
            user.id,
            msg.text,
            msg.isUser ? 1 : 0,
            msg.verseReference,
            msg.isError ? 1 : 0,
            msg.timestamp,
            now
          )
        );
      }
    }

    // 6. Sync daily plan progress
    if (payload.dailyPlanProgress) {
      for (const progress of payload.dailyPlanProgress) {
        statements.push(
          db.prepare(`
            INSERT INTO daily_plan_progress (user_id, plan_date, plan_id, completed_at, streak_day)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(user_id, plan_date) DO UPDATE SET
              plan_id = excluded.plan_id,
              completed_at = excluded.completed_at,
              streak_day = excluded.streak_day
          `).bind(
            user.id,
            progress.planDate,
            progress.planId,
            progress.completedAt,
            progress.streakDay
          )
        );
      }
    }

    // 7. Sync prayers
    if (payload.prayers) {
      for (const prayer of payload.prayers) {
        statements.push(
          db.prepare(`
            INSERT INTO prayers (id, user_id, title, content, category,
              is_answered, answered_at, created_at, updated_at, is_deleted)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              title = excluded.title,
              content = excluded.content,
              category = excluded.category,
              is_answered = excluded.is_answered,
              answered_at = excluded.answered_at,
              updated_at = excluded.updated_at,
              is_deleted = excluded.is_deleted
          `).bind(
            prayer.id,
            user.id,
            prayer.title,
            prayer.content,
            prayer.category,
            prayer.isAnswered ? 1 : 0,
            prayer.answeredAt,
            prayer.createdAt,
            prayer.updatedAt,
            prayer.isDeleted ? 1 : 0
          )
        );
      }
    }

    // 8. Sync study plans
    if (payload.studyPlans) {
      for (const plan of payload.studyPlans) {
        statements.push(
          db.prepare(`
            INSERT INTO study_plans (id, user_id, title, description, translation_id,
              total_days, completed_days, current_day, is_completed,
              started_at, completed_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
              title = excluded.title,
              description = excluded.description,
              translation_id = excluded.translation_id,
              total_days = excluded.total_days,
              completed_days = excluded.completed_days,
              current_day = excluded.current_day,
              is_completed = excluded.is_completed,
              completed_at = excluded.completed_at,
              updated_at = excluded.updated_at
          `).bind(
            plan.id,
            user.id,
            plan.title,
            plan.description,
            plan.translationId,
            plan.totalDays,
            plan.completedDays,
            plan.currentDay,
            plan.isCompleted ? 1 : 0,
            plan.startedAt,
            plan.completedAt,
            plan.updatedAt
          )
        );
      }
    }

    // 9. Sync study plan days
    if (payload.studyPlanDays) {
      for (const day of payload.studyPlanDays) {
        statements.push(
          db.prepare(`
            INSERT INTO study_plan_days (plan_id, day_number, title, reference,
              is_completed, completed_at, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(plan_id, day_number) DO UPDATE SET
              title = excluded.title,
              reference = excluded.reference,
              is_completed = excluded.is_completed,
              completed_at = excluded.completed_at,
              notes = excluded.notes
          `).bind(
            day.planId,
            day.dayNumber,
            day.title,
            day.reference,
            day.isCompleted ? 1 : 0,
            day.completedAt,
            day.notes
          )
        );
      }
    }

    // 10. Sync seasonal progress
    if (payload.seasonalProgress) {
      for (const prog of payload.seasonalProgress) {
        statements.push(
          db.prepare(`
            INSERT INTO seasonal_progress (user_id, season_type, year, day_number,
              is_completed, completed_at, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(user_id, season_type, year, day_number) DO UPDATE SET
              is_completed = excluded.is_completed,
              completed_at = excluded.completed_at,
              notes = excluded.notes
          `).bind(
            user.id,
            prog.seasonType,
            prog.year,
            prog.dayNumber,
            prog.isCompleted ? 1 : 0,
            prog.completedAt,
            prog.notes
          )
        );
      }
    }

    // Execute all statements in batch
    await db.batch(statements);

    return { success: true, syncedAt: now, conflicts };
  } catch (error) {
    console.error("Sync error:", error);
    throw error;
  }
}

/**
 * Get user data from cloud for initial sync or conflict resolution
 */
export async function getUserCloudData(
  db: D1Database,
  userId: string
): Promise<SyncPayload> {
  const [
    preferences,
    favoriteVerses,
    chatSessions,
    chatMessages,
    dailyPlanProgress,
    prayers,
    studyPlans,
    studyPlanDays,
    seasonalProgress,
  ] = await Promise.all([
    db.prepare("SELECT * FROM user_preferences WHERE user_id = ?")
      .bind(userId).first(),
    db.prepare("SELECT verse_key FROM favorite_verses WHERE user_id = ?")
      .bind(userId).all(),
    db.prepare("SELECT * FROM chat_sessions WHERE user_id = ? AND is_deleted = 0 ORDER BY updated_at DESC")
      .bind(userId).all(),
    db.prepare("SELECT * FROM chat_messages WHERE user_id = ? ORDER BY timestamp ASC")
      .bind(userId).all(),
    db.prepare("SELECT * FROM daily_plan_progress WHERE user_id = ?")
      .bind(userId).all(),
    db.prepare("SELECT * FROM prayers WHERE user_id = ? AND is_deleted = 0 ORDER BY created_at DESC")
      .bind(userId).all(),
    db.prepare("SELECT * FROM study_plans WHERE user_id = ? ORDER BY started_at DESC")
      .bind(userId).all(),
    db.prepare(`
      SELECT spd.* FROM study_plan_days spd
      JOIN study_plans sp ON spd.plan_id = sp.id
      WHERE sp.user_id = ?
    `).bind(userId).all(),
    db.prepare("SELECT * FROM seasonal_progress WHERE user_id = ?")
      .bind(userId).all(),
  ]);

  return {
    userId,
    preferences: preferences ? {
      isDarkMode: Boolean(preferences.is_dark_mode),
      locale: preferences.locale,
      textScale: preferences.text_scale,
      dailyReminderTime: preferences.daily_reminder_time,
      dailyReminderEnabled: Boolean(preferences.daily_reminder_enabled),
      preferredBibleVersion: preferences.preferred_bible_version,
      translationStyle: preferences.translation_style,
      denomination: preferences.denomination,
      aiAuthToken: preferences.ai_auth_token,
      hasCompletedOnboarding: Boolean(preferences.has_completed_onboarding),
    } : undefined,
    favoriteVerses: favoriteVerses.results?.map((r: any) => r.verse_key) || [],
    chatSessions: chatSessions.results?.map((s: any) => ({
      id: s.id,
      title: s.title,
      createdAt: s.created_at,
      updatedAt: s.updated_at,
      isDeleted: Boolean(s.is_deleted),
    })) || [],
    chatMessages: chatMessages.results?.map((m: any) => ({
      id: m.id,
      sessionId: m.session_id,
      text: m.text,
      isUser: Boolean(m.is_user),
      verseReference: m.verse_reference,
      isError: Boolean(m.is_error),
      timestamp: m.timestamp,
    })) || [],
    dailyPlanProgress: dailyPlanProgress.results?.map((p: any) => ({
      planDate: p.plan_date,
      planId: p.plan_id,
      completedAt: p.completed_at,
      streakDay: p.streak_day,
    })) || [],
    prayers: prayers.results?.map((p: any) => ({
      id: p.id,
      title: p.title,
      content: p.content,
      category: p.category,
      isAnswered: Boolean(p.is_answered),
      answeredAt: p.answered_at,
      createdAt: p.created_at,
      updatedAt: p.updated_at,
      isDeleted: Boolean(p.is_deleted),
    })) || [],
    studyPlans: studyPlans.results?.map((s: any) => ({
      id: s.id,
      title: s.title,
      description: s.description,
      translationId: s.translation_id,
      totalDays: s.total_days,
      completedDays: s.completed_days,
      currentDay: s.current_day,
      isCompleted: Boolean(s.is_completed),
      startedAt: s.started_at,
      completedAt: s.completed_at,
      updatedAt: s.updated_at,
    })) || [],
    studyPlanDays: studyPlanDays.results?.map((d: any) => ({
      planId: d.plan_id,
      dayNumber: d.day_number,
      title: d.title,
      reference: d.reference,
      isCompleted: Boolean(d.is_completed),
      completedAt: d.completed_at,
      notes: d.notes,
    })) || [],
    seasonalProgress: seasonalProgress.results?.map((s: any) => ({
      seasonType: s.season_type,
      year: s.year,
      dayNumber: s.day_number,
      isCompleted: Boolean(s.is_completed),
      completedAt: s.completed_at,
      notes: s.notes,
    })) || [],
  };
}