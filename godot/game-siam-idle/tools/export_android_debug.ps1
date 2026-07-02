param(
    [ValidateSet("apk", "aab")]
    [string]$Format = "apk"
)

$ErrorActionPreference = "Stop"

$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$project = "C:\Users\ADMIN\Documents\GAME IDLE\godot\game-siam-idle"
$outDir = Join-Path $project "exports\android"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Stop-GradleDaemons {
    Get-CimInstance Win32_Process |
        Where-Object { $_.CommandLine -like '*GradleDaemon*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

if ($Format -eq "aab") {
    $preset = "Android Debug AAB"
    $output = Join-Path $outDir "game-siam-idle-debug.aab"
    $templateFlag = "--install-android-build-template"
} else {
    $preset = "Android Debug APK"
    $output = Join-Path $outDir "game-siam-idle-debug.apk"
    $templateFlag = ""
}

$argsLine = if ($templateFlag -ne "") {
    '--headless --path "{0}" {1} --export-debug "{2}" "{3}"' -f $project, $templateFlag, $preset, $output
} else {
    '--headless --path "{0}" --export-debug "{1}" "{2}"' -f $project, $preset, $output
}

$process = Start-Process -FilePath $godot -ArgumentList $argsLine -NoNewWindow -PassThru
$completed = $process.WaitForExit(480000)
if (-not $completed) {
    $outputExists = Test-Path -LiteralPath $output
    $outputSize = if ($outputExists) { (Get-Item -LiteralPath $output).Length } else { 0 }
    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    Stop-GradleDaemons
    if ($outputSize -lt 10000000) {
        throw "Godot Android $Format export timed out and did not produce a valid output."
    }
} elseif ($null -ne $process.ExitCode -and $process.ExitCode -ne 0) {
    Stop-GradleDaemons
    throw "Godot Android $Format export failed with exit code $($process.ExitCode)."
} elseif (-not (Test-Path -LiteralPath $output) -or (Get-Item -LiteralPath $output).Length -lt 10000000) {
    Stop-GradleDaemons
    throw "Godot Android $Format export did not produce a valid output."
}

Stop-GradleDaemons
Get-Item -LiteralPath $output
