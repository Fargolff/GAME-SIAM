$ErrorActionPreference = "Stop"

$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$project = "C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle"

foreach ($phase in 1..14) {
    $validator = "res://scripts/tools/validate_phase$phase.gd"
    $argsLine = '--headless --path "{0}" --script {1}' -f $project, $validator
    $process = Start-Process -FilePath $godot -ArgumentList $argsLine -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Validator failed: $validator"
    }
}

powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\check_toolchain.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\export_android_debug.ps1" -Format apk
powershell -NoProfile -ExecutionPolicy Bypass -File "$project\tools\export_android_debug.ps1" -Format aab

$apk = Join-Path $project "exports\android\game-siam-idle-debug.apk"
$aab = Join-Path $project "exports\android\game-siam-idle-debug.aab"
Get-Item -LiteralPath $apk, $aab | Select-Object FullName, Length
