$ErrorActionPreference = 'Stop'
$voiceProjectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $voiceProjectRoot
try {
    $voiceFlutter = Join-Path $voiceProjectRoot '..\.flutter-sdk\bin\flutter.bat'
    $voiceFixture = Get-Content -LiteralPath 'tool/speech_browser_fixture.js' -Raw -Encoding utf8
    $voiceHarness = Get-Content -LiteralPath 'tool/speech_browser_check.dart' -Raw -Encoding utf8
    $voiceHarness = [regex]::Replace($voiceHarness, '(?m)^import .*;\r?\n', '')
    $voiceHarness = $voiceHarness.Replace('Future<void> main()', 'Future<void> runSpeechAdapterChecks()')
    $voiceWrapper = @"
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, avoid_print
@TestOn('browser')
library;
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:bible_path/core/platform/speech_output_web.dart';
@JS('eval')
external JSAny? injectFixture(JSString source);
void main() {
  test('web speech adapter uses real implementation with deterministic browser seams', () async {
    injectFixture(r'''$voiceFixture'''.toJS);
    html.document.body!.append(html.PreElement()..id = 'results');
    await runSpeechAdapterChecks();
    final report = html.document.getElementById('results')!.text!;
    print(report);
    expect(html.document.title, startsWith('PASS'), reason: report);
    expect(report, contains('adapter checks passed'));
  });
}
$voiceHarness
"@
    New-Item -ItemType Directory -Path '.tmp/voice-validation' -Force | Out-Null
    New-Item -ItemType Directory -Path 'test/browser' -Force | Out-Null
    $voiceTestPath = Join-Path $voiceProjectRoot 'test/browser/generated_speech_adapter_test.dart'
    [System.IO.File]::WriteAllText($voiceTestPath, $voiceWrapper, [System.Text.UTF8Encoding]::new($false))
    $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
    $env:DART_SUPPRESS_ANALYTICS = 'true'
    & $voiceFlutter --suppress-analytics test --no-pub --platform chrome --dart-define=AI_API_URL=https://speech.fixture.invalid $voiceTestPath
    if ($LASTEXITCODE -ne 0) { throw "Browser adapter test failed (exit $LASTEXITCODE)" }
} finally {
    $voiceGeneratedPath = Join-Path $voiceProjectRoot 'test/browser/generated_speech_adapter_test.dart'
    if (Test-Path -LiteralPath $voiceGeneratedPath) { Remove-Item -LiteralPath $voiceGeneratedPath }
    Pop-Location
}
