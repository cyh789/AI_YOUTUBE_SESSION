param(
    [string]$InputDir = "tts",
    [string]$OutputDir = "tts_audio",
    [string]$VoiceName = "Microsoft Heami Desktop",
    [int]$Rate = 0,
    [string]$Pattern = "*.txt",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Speech

$projectRoot = Split-Path -Parent $PSScriptRoot
$resolvedInputDir = Join-Path $projectRoot $InputDir
$resolvedOutputDir = Join-Path $projectRoot $OutputDir

if (-not (Test-Path $resolvedInputDir)) {
    throw "입력 폴더를 찾을 수 없습니다: $resolvedInputDir"
}

if (-not (Test-Path $resolvedOutputDir)) {
    New-Item -ItemType Directory -Path $resolvedOutputDir | Out-Null
}

$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer
$installedVoices = $synthesizer.GetInstalledVoices() | ForEach-Object { $_.VoiceInfo.Name }

if ($installedVoices -notcontains $VoiceName) {
    $available = ($installedVoices -join ", ")
    throw "지정한 음성을 찾을 수 없습니다: $VoiceName`n사용 가능한 음성: $available"
}

$synthesizer.SelectVoice($VoiceName)
$synthesizer.Rate = $Rate

$textFiles = Get-ChildItem -Path $resolvedInputDir -Filter $Pattern -File | Sort-Object Name

if (-not $textFiles) {
    throw "대상 텍스트 파일이 없습니다: $resolvedInputDir\\$Pattern"
}

$generated = @()

foreach ($file in $textFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outputPath = Join-Path $resolvedOutputDir "$baseName.wav"

    if ((Test-Path $outputPath) -and -not $Overwrite) {
        Write-Host "건너뜀: $outputPath"
        continue
    }

    $text = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host "건너뜀(빈 파일): $($file.FullName)"
        continue
    }

    $synthesizer.SetOutputToWaveFile($outputPath)
    $synthesizer.Speak($text.Trim())
    $synthesizer.SetOutputToNull()

    $generated += $outputPath
    Write-Host "생성 완료: $outputPath"
}

$synthesizer.Dispose()

Write-Host ""
Write-Host "TTS 생성 작업이 끝났습니다."
Write-Host "입력 폴더: $resolvedInputDir"
Write-Host "출력 폴더: $resolvedOutputDir"
Write-Host "음성: $VoiceName"
Write-Host "생성 파일 수: $($generated.Count)"
