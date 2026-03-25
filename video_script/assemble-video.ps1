param(
    [string]$AudioDir = "tts_audio",
    [string]$ImageDir = "output",
    [string]$WorkDir = "video_work",
    [string]$OutputFile = "video_output\video-01.mp4",
    [switch]$Overwrite,
    [switch]$PrintPlan
)

$ErrorActionPreference = "Stop"

function Resolve-ProjectPath {
    param([string]$BaseDir, [string]$RelativePath)

    $projectRoot = Split-Path -Parent $BaseDir
    return Join-Path $projectRoot $RelativePath
}

function Get-SceneImageMap {
    return @{
        "scene-01-hook" = "scene-01-hook.png"
        "scene-02-priority" = "scene-01-hook.png"
        "scene-03-intro" = "scene-01-hook.png"
        "scene-04-disclaimer" = "scene-01-hook.png"
        "scene-05-omega3-a" = "scene-05-omega3.png"
        "scene-05-omega3-b" = "scene-05-omega3.png"
        "scene-10-vitamin-d-a" = "scene-10-vitamin-d.png"
        "scene-10-vitamin-d-b" = "scene-10-vitamin-d.png"
        "scene-15-magnesium-a" = "scene-15-magnesium.png"
        "scene-15-magnesium-b" = "scene-15-magnesium.png"
        "scene-20-summary" = "scene-20-summary.png"
        "scene-23-balance" = "scene-23-balance.png"
        "scene-24-cta" = "scene-25-ending.png"
        "scene-03-omega3-a" = "scene-05-omega3.png"
        "scene-04-omega3-b" = "scene-05-omega3.png"
        "scene-05-omega3-c" = "scene-05-omega3.png"
        "scene-06-vitamind-a" = "scene-10-vitamin-d.png"
        "scene-07-vitamind-b" = "scene-10-vitamin-d.png"
        "scene-08-vitamind-c" = "scene-10-vitamin-d.png"
        "scene-09-magnesium-a" = "scene-15-magnesium.png"
        "scene-10-magnesium-b" = "scene-15-magnesium.png"
        "scene-11-magnesium-c" = "scene-15-magnesium.png"
        "scene-12-balance" = "scene-23-balance.png"
        "scene-13-ending" = "scene-25-ending.png"
    }
}

$scriptDir = $PSScriptRoot
$projectRoot = Split-Path -Parent $scriptDir
$resolvedAudioDir = Join-Path $projectRoot $AudioDir
$resolvedImageDir = Join-Path $projectRoot $ImageDir
$resolvedWorkDir = Join-Path $projectRoot $WorkDir
$resolvedOutputFile = Join-Path $projectRoot $OutputFile
$resolvedOutputDir = Split-Path -Parent $resolvedOutputFile

if (-not (Test-Path $resolvedAudioDir)) {
    throw "오디오 폴더를 찾을 수 없습니다: $resolvedAudioDir"
}

if (-not (Test-Path $resolvedImageDir)) {
    throw "이미지 폴더를 찾을 수 없습니다: $resolvedImageDir"
}

if (-not (Test-Path $resolvedWorkDir)) {
    New-Item -ItemType Directory -Path $resolvedWorkDir | Out-Null
}

if (-not (Test-Path $resolvedOutputDir)) {
    New-Item -ItemType Directory -Path $resolvedOutputDir | Out-Null
}

$sceneImageMap = Get-SceneImageMap
$audioFiles = Get-ChildItem -Path $resolvedAudioDir -Filter "*.wav" -File | Sort-Object Name

if (-not $audioFiles) {
    throw "오디오 파일이 없습니다: $resolvedAudioDir"
}

$plan = foreach ($audio in $audioFiles) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($audio.Name)
    $imageName = $sceneImageMap[$baseName]

    if (-not $imageName) {
        throw "장면 이미지 매핑이 없습니다: $baseName"
    }

    $imagePath = Join-Path $resolvedImageDir $imageName
    if (-not (Test-Path $imagePath)) {
        throw "매핑된 이미지 파일을 찾을 수 없습니다: $imagePath"
    }

    [PSCustomObject]@{
        Scene = $baseName
        Audio = $audio.FullName
        Image = $imagePath
        Segment = Join-Path $resolvedWorkDir "$baseName.mp4"
    }
}

if ($PrintPlan) {
    $plan | Format-Table -AutoSize | Out-String | Write-Host
    Write-Host "장면 매핑 계획을 출력했습니다."
    exit 0
}

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
$ffprobe = Get-Command ffprobe -ErrorAction SilentlyContinue

if (-not $ffmpeg -or -not $ffprobe) {
    throw "ffmpeg 또는 ffprobe를 찾을 수 없습니다. 먼저 ffmpeg를 설치한 뒤 다시 실행하세요."
}

$concatFile = Join-Path $resolvedWorkDir "concat-list.txt"
$concatLines = @()

foreach ($item in $plan) {
    if ((Test-Path $item.Segment) -and -not $Overwrite) {
        $concatLines += "file '$($item.Segment.Replace('\', '/'))'"
        continue
    }

    $duration = & $ffprobe.Source -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $item.Audio
    if (-not $duration) {
        throw "오디오 길이를 읽을 수 없습니다: $($item.Audio)"
    }

    & $ffmpeg.Source -y `
        -loop 1 `
        -i $item.Image `
        -i $item.Audio `
        -c:v libx264 `
        -tune stillimage `
        -c:a aac `
        -b:a 192k `
        -pix_fmt yuv420p `
        -shortest `
        -t $duration `
        $item.Segment | Out-Null

    $concatLines += "file '$($item.Segment.Replace('\', '/'))'"
    Write-Host "세그먼트 생성 완료: $($item.Segment)"
}

Set-Content -Path $concatFile -Value $concatLines -Encoding UTF8

& $ffmpeg.Source -y `
    -f concat `
    -safe 0 `
    -i $concatFile `
    -c copy `
    $resolvedOutputFile | Out-Null

Write-Host ""
Write-Host "영상 조립이 완료되었습니다."
Write-Host "출력 파일: $resolvedOutputFile"
