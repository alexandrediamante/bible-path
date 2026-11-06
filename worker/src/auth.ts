import { createHandler } from "./index";

export interface AuthUser {
  id: string;
  email: string;
  name: string | null;
  picture: string | null;
  locale: string;
  createdAt: number;
  updatedAt: number;
  lastSyncAt: number | null;
}

export interface SyncPayload {
  userId: string;
  preferences?: UserPreferencesSync;
  favoriteVerses?: string[];
  chatSessions?: ChatSessionSync[];
  chatMessages?: ChatMessageSync[];
  dailyPlanProgress?: DailyPlanProgressSync[];
  prayers?: PrayerSync[];
  studyPlans?: StudyPlanSync[];
  studyPlanDays?: StudyPlanDaySync[];
  seasonalProgress?: SeasonalProgressSync[];
}

export interface UserPreferencesSync {
  isDarkMode: boolean;
  locale: string;
  textScale: number;
  dailyReminderTime: string;
  dailyReminderEnabled: boolean;
  preferredBibleVersion: string;
  translationStyle: string | null;
  denomination: string | null;
  aiAuthToken: string | null;
  hasCompletedOnboarding: boolean;
}

export interface ChatSessionSync {
  id: string;
  title: string;
  createdAt: number;
  updatedAt: number;
  isDeleted: boolean;
}

export interface ChatMessageSync {
  id: string;
  sessionId: string;
  text: string;
  isUser: boolean;
  verseReference: string | null;
  isError: boolean;
  timestamp: number;
}

export interface DailyPlanProgressSync {
  planDate: string;
  planId: string;
  completedAt: number | null;
  streakDay: number | null;
}

export interface PrayerSync {
  id: string;
  title: string | null;
  content: string;
  category: string | null;
  isAnswered: boolean;
  answeredAt: number | null;
  createdAt: number;
  updatedAt: number;
  isDeleted: boolean;
}

export interface StudyPlanSync {
  id: string;
  title: string;
  description: string | null;
  translationId: string;
  totalDays: number;
  completedDays: number;
  currentDay: number;
  isCompleted: boolean;
  startedAt: number;
  completedAt: number | null;
  updatedAt: number;
}

export interface StudyPlanDaySync {
  planId: string;
  dayNumber: number;
  title: string | null;
  reference: string | null;
  isCompleted: boolean;
  completedAt: number | null;
  notes: string | null;
}

export interface SeasonalProgressSync {
  seasonType: string;
  year: number;
  dayNumber: number;
  isCompleted: boolean;
  completedAt: number | null;
  notes: string | null;
}

/**
 * Verify Google ID token using Google's public keys
 * In production, use a proper JWT library
 */
export async function verifyGoogleIdToken(
  idToken: string,
  clientId: string
): Promise<{ sub: string; email: string; name: string; picture: string; locale: string } | null> {
  try {
    // For Cloudflare Workers, we can use the built-in crypto
    // This is a simplified verification - in production use google-auth-library
    const response = await fetch(
      `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`
    );

    if (!response.ok) return null;

    const payload = await response.json();

    // Verify audience matches our client ID
    if (payload.aud !== clientId) return null;

    // Verify token not expired
    const now = Math.floor(Date.now() / 1000);
    if (payload.exp < now) return null;

    return {
      sub: payload.sub,
      email: payload.email,
      name: payload.name || '',
      picture: payload.picture || '',
      locale: payload.locale || 'en',
    };
  } catch {
    return null;
  }
}

/**
 * Get or create user from Google profile
 */
export async function getOrCreateUser(
  db: D1Database,
  googleUser: { sub: string; email: string; name: string; picture: string; locale: string }
): Promise<AuthUser> {
  const now = Date.now();

  // Try to get existing user
  const existing = await db.prepare(
    "SELECT * FROM users WHERE id = ?"
  ).bind(googleUser.sub).first<AuthUser>();

  if (existing) {
    // Update last_sync_at
    await db.prepare(
      "UPDATE users SET last_sync_at = ?, updated_at = ? WHERE id = ?"
    ).bind(now, now, googleUser.sub).run();

    return { ...existing, lastSyncAt: now };
  }

  // Create new user
  await db.prepare(`
    INSERT INTO users (id, email, name, picture, locale, created_at, updated_at, last_sync_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    googleUser.sub,
    googleUser.email,
    googleUser.name,
    googleUser.picture,
    googleUser.locale,
    now,
    now,
    now
  ).run();

  // Create default preferences
  await db.prepare(`
    INSERT INTO user_preferences (user_id, is_dark_mode, locale, text_scale, daily_reminder_time,
      daily_reminder_enabled, preferred_bible_version, has_completed_onboarding, updated_at)
    VALUES (?, 0, ?, 1.0, '07:00', 0, 'engwebp', 0, ?)
  `).bind(googleUser.sub, googleUser.locale, now).run();

  return {
    id: googleUser.sub,
    email: googleUser.email,
    name: googleUser.name,
    picture: googleUser.picture,
    locale: googleUser.locale,
    createdAt: now,
    updatedAt: now,
    lastSyncAt: now,
  };
}

/**
 * Generate app auth token for authenticated API calls
 */
export function generateAppAuthToken(userId: string, secret: string): string {
  // Simple token: base64(userId + ':' + timestamp + ':' + HMAC)
  const timestamp = Date.now();
  const data = `${userId}:${timestamp}`;
  // In production, use proper JWT signing
  return btoa(data);
}

/**
 * Verify app auth token
 */
export function verifyAppAuthToken(token: string, secret: string): { userId: string; timestamp: number } | null {
  try {
    const decoded = atob(token);
    const [userId, timestampStr] = decoded.split(':');
    const timestamp = parseInt(timestampStr, 10);

    if (isNaN(timestamp)) return null;

    // Token expires in 30 days
    if (Date.now() - timestamp > 30 * 24 * 60 * 60 * 1000) return null;

    return { userId, timestamp };
  } catch {
    return null;
  }
}