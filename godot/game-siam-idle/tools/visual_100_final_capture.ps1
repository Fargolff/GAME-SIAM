param(
    [string]$RunDir = ""
)

$ErrorActionPreference = "Stop"

$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$project = "C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle"
if ($RunDir -eq "") {
    $RunDir = "C:\Users\ADMIN\Documents\GAME IDLE\run\visual-100-final-$(Get-Date -Format yyyyMMdd-HHmmss)"
}
New-Item -ItemType Directory -Force $RunDir | Out-Null

function Quote-Arg($arg) {
    $text = [string]$arg
    if ($text -match '[\s"]') {
        return '"' + ($text -replace '"', '\"') + '"'
    }
    return $text
}

function Run-Validator($name) {
    $argLine = @("--headless", "--path", $project, "--script", "res://scripts/tools/$name") | ForEach-Object { Quote-Arg $_ }
    $process = Start-Process -FilePath $godot -ArgumentList ($argLine -join " ") -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$RunDir\$name.stdout.txt" -RedirectStandardError "$RunDir\$name.stderr.txt"
    if ($process.ExitCode -ne 0) { throw "$name failed" }
}

function Run-Movie($avi) {
    $argsLine = '--display-driver windows --rendering-driver opengl3_angle --path "{0}" --write-movie "{1}" --fixed-fps 30' -f $project, $avi
    $process = Start-Process -FilePath $godot -ArgumentList $argsLine -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Godot movie failed: $avi" }
}

"validate_phase3.gd","validate_phase4.gd","validate_phase5.gd","validate_phase8.gd","validate_phase9.gd","validate_phase10.gd","validate_skill_roster.gd","validate_first_session_fun.gd" | ForEach-Object { Run-Validator $_ }
$baselineValidators = Get-ChildItem "$project\scripts\tools" -Filter "validate_???_baseline.gd" | Sort-Object Name
if ($baselineValidators.Count -ne 40) { throw "Expected 40 baseline validators, found $($baselineValidators.Count)" }
$baselineValidators | ForEach-Object { Run-Validator $_.Name }

$env:GAME_SIAM_PROFILE_PATH = "$RunDir\battle_ready_profile.json"
$env:GAME_SIAM_CAPTURE_FRAME_DIR = "$RunDir\frames_battle_ready"
$env:GAME_SIAM_CAPTURE_QUIT_AFTER = "4"
$env:GAME_SIAM_AUTOSTART = "0"
Run-Movie "$RunDir\battle_ready.avi"
ffmpeg -y -i "$RunDir\battle_ready.avi" -c:v libx264 -pix_fmt yuv420p -crf 18 "$RunDir\battle_ready.mp4"
ffmpeg -y -i "$RunDir\battle_ready.mp4" -vf "fps=1,scale=320:-1,tile=4x2" -frames:v 1 "$RunDir\battle_ready_contact.jpg"

$env:GAME_SIAM_PROFILE_PATH = "$RunDir\battle_running_victory_profile.json"
$env:GAME_SIAM_CAPTURE_FRAME_DIR = "$RunDir\frames_battle_running_victory"
$env:GAME_SIAM_CAPTURE_QUIT_AFTER = "18"
$env:GAME_SIAM_AUTOSTART = "1"
$env:GAME_SIAM_AUTO_SKILL_TEST = "1"
$env:GAME_SIAM_SKILL_TEST_LOG = "1"
$env:GAME_SIAM_SKILL_TEST_LOG_PATH = "$RunDir\battle_running_victory.skills.tsv"
$env:GAME_SIAM_PLAYTEST_WAVE = "1"
$env:GAME_SIAM_PLAYTEST_LEVEL = "3"
Run-Movie "$RunDir\battle_running_victory.avi"
ffmpeg -y -i "$RunDir\battle_running_victory.avi" -c:v libx264 -pix_fmt yuv420p -crf 18 "$RunDir\battle_running_victory.mp4"
ffmpeg -y -i "$RunDir\battle_running_victory.mp4" -vf "fps=1,scale=320:-1,tile=6x3" -frames:v 1 "$RunDir\battle_running_victory_contact.jpg"

$env:GAME_SIAM_SKILL_SHOWCASE_ALL = "1"
$env:GAME_SIAM_SKILL_SHOWCASE_QUIT = "1"
$env:GAME_SIAM_SKILL_SHOWCASE_STDOUT = "1"
$env:GAME_SIAM_SKILL_SHOWCASE_LOG_PATH = "$RunDir\skill_showcase_all40.logic.tsv"
$env:GAME_SIAM_SKILL_SHOWCASE_FRAME_DIR = "$RunDir\frames_skill_showcase_all40"
Run-Movie "$RunDir\skill_showcase_all40.avi"
ffmpeg -y -i "$RunDir\skill_showcase_all40.avi" -c:v libx264 -pix_fmt yuv420p -crf 18 "$RunDir\skill_showcase_all40.mp4"
ffmpeg -y -i "$RunDir\skill_showcase_all40.mp4" -vf "fps=0.8,scale=320:180,tile=5x8" -frames:v 1 "$RunDir\skill_showcase_all40_contact.jpg"

$lineCount = (Get-Content "$RunDir\skill_showcase_all40.logic.tsv").Count
if ($lineCount -ne 40) { throw "All-40 showcase logged $lineCount rows, expected 40" }

Write-Host "visual 100 final capture complete: $RunDir"
