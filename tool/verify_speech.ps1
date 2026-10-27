param(
    [switch]$Serve,
    [switch]$Adapter,
    [string]$AiApiUrl = "https://bible-path-chat.bible-path-worker.workers.dev"
)
$ErrorActionPreference = 'Stop'
$voiceProjectRoot = Split-Path -Parent $PSScriptRoot
$voiceFlutter = Join-Path $voiceProjectRoot '..\.flutter-sdk\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $voiceFlutter)) {
    $voiceFlutter = Join-Path $voiceProjectRoot 'flutter\bin\flutter.bat'
}
if (-not (Test-Path -LiteralPath $voiceFlutter)) { throw 'Flutter local não encontrado.' }
$voiceDart = Join-Path (Split-Path -Parent $voiceFlutter) 'cache\dart-sdk\bin\dart.exe'
function Invoke-VoiceCheck {
    param([string]$Program, [string[]]$CheckArgs)
    & $Program @CheckArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Verificação falhou: $Program $($CheckArgs -join ' ') (exit $LASTEXITCODE)"
    }
}
Push-Location $voiceProjectRoot
try {
    $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
    $env:DART_SUPPRESS_ANALYTICS = 'true'
    if ($Adapter) {
        $voiceAdapterDir = Join-Path $voiceProjectRoot '.tmp\speech-browser'
        New-Item -ItemType Directory -Path $voiceAdapterDir -Force | Out-Null
        Invoke-VoiceCheck $voiceDart @(
            'compile','js','-DAI_API_URL=https://speech.fixture.invalid',
            'tool/speech_browser_check.dart','-o',
            (Join-Path $voiceAdapterDir 'speech_browser_check.js')
        )
        Copy-Item -LiteralPath 'tool/speech_browser_fixture.js' -Destination $voiceAdapterDir
        Copy-Item -LiteralPath 'tool/speech_browser_check.html' -Destination $voiceAdapterDir
        Write-Host 'Abra http://127.0.0.1:8766/speech_browser_check.html'
        Write-Host 'Este teste usa eventos sintéticos e não comprova som físico.'
        Invoke-VoiceCheck 'python' @('-m','http.server','8766','--bind','127.0.0.1','--directory',$voiceAdapterDir)
    } else {
        Invoke-VoiceCheck $voiceDart @('tool/speech_policy_check.dart')
        Invoke-VoiceCheck $voiceFlutter @('--suppress-analytics','analyze','--no-pub')
        Invoke-VoiceCheck $voiceFlutter @('--suppress-analytics','test','--no-pub','--concurrency=1')
        Invoke-VoiceCheck 'npm.cmd' @('--prefix','worker','test')
        Invoke-VoiceCheck 'npm.cmd' @('--prefix','worker','run','typecheck')
        Invoke-VoiceCheck 'node' @('--test','tool/generate_service_worker.test.mjs','tool/pwa_files.test.mjs','tool/verify_content.test.mjs')
        Invoke-VoiceCheck 'node' @('tool/verify_content.mjs')
        Invoke-VoiceCheck $voiceFlutter @('--suppress-analytics','build','web','--release','--no-pub','--base-href','/',"--dart-define=AI_API_URL=$AiApiUrl")
        Invoke-VoiceCheck 'node' @('tool/generate_service_worker.mjs','build/web')
        Write-Host 'Verificações locais concluídas. Confirmar som no iPhone separadamente.'
        if ($Serve) {
            Write-Host 'Abra http://127.0.0.1:8765 no computador. Ctrl+C encerra.'
            Invoke-VoiceCheck 'python' @('-m','http.server','8765','--bind','127.0.0.1','--directory',(Join-Path $voiceProjectRoot 'build\web'))
        }
    }
} finally {
    Pop-Location
}
