import 'package:bible_path/features/holy_calendar/holy_calendar_landmarks.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = ['en', 'pt', 'es', 'fr', 'de', 'it', 'ru'];

  test('builds sorted landmarks for every tradition and supported locale', () {
    for (final tradition in LiturgicalTradition.values) {
      for (final locale in locales) {
        final calendar = buildHolyCalendarLandmarks(
          year: 2026,
          tradition: tradition,
          locale: locale,
        );

        expect(calendar.year, 2026);
        expect(calendar.locale, locale);
        expect(calendar.tradition, tradition);
        expect(calendar.days.length, greaterThanOrEqualTo(10));
        expect(
          calendar.days.map((day) => day.date).toList(),
          orderedEquals(calendar.days.map((day) => day.date).toList()..sort()),
        );
        expect(
          calendar.days.every((day) => day.date.startsWith('2026-')),
          isTrue,
        );
      }
    }
  });

  test('uses the correct 2026 movable feast dates', () {
    final catholic = buildHolyCalendarLandmarks(
      year: 2026,
      tradition: LiturgicalTradition.catholic,
      locale: 'pt',
    );
    final orthodox = buildHolyCalendarLandmarks(
      year: 2026,
      tradition: LiturgicalTradition.orthodox,
      locale: 'pt',
    );

    expect(catholic.getDay('2026-04-05')?.dayName, 'Domingo de Páscoa');
    expect(orthodox.getDay('2026-04-12')?.dayName, 'Páscoa Ortodoxa');
    expect(orthodox.getDay('2026-12-25')?.dayName, 'Natividade de Cristo');
    expect(
      catholic.getDay('2026-11-29')?.dayName,
      'Primeiro Domingo do Advento',
    );
  });

  test('falls back to English for an unsupported locale', () {
    final calendar = buildHolyCalendarLandmarks(
      year: 2026,
      tradition: LiturgicalTradition.protestant,
      locale: 'xx',
    );

    expect(calendar.locale, 'en');
    expect(calendar.getDay('2026-10-31')?.dayName, 'Reformation Day');
  });
}
