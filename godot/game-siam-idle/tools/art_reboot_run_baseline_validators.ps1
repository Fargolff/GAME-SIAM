param(
    [string]$RunDir = ""
)

$ErrorActionPreference = "Stop"

$workspace = "C:\Users\ADMIN\Documents\GAME IDLE"
$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$project = "$workspace\godot\game-siam-idle"
if ($RunDir -eq "") {
    $RunDir = "$workspace\run\art-reboot-baseline-$(Get-Date -Format yyyyMMdd-HHmmss)"
}
New-Item -ItemType Directory -Force $RunDir | Out-Null

$results = @()
$failed = $false

function Safe-Name($name) {
    return ($name -replace '[^A-Za-z0-9_.-]', '_')
}

function Quote-Arg($arg) {
    $text = [string]$arg
    if ($text -match '[\s"]') {
        return '"' + ($text -replace '"', '\"') + '"'
    }
    return $text
}

function Add-Result($name, $exitCode, $expectedExit, $stdout, $stderr, $seconds) {
    $script:results += [pscustomobject]@{
        name = $name
        exit_code = $exitCode
        expected_exit = $expectedExit
        ok = ($exitCode -eq $expectedExit)
        seconds = [math]::Round($seconds, 3)
        stdout = $stdout
        stderr = $stderr
        stdout_bytes = if (Test-Path $stdout) { (Get-Item $stdout).Length } else { 0 }
        stderr_bytes = if (Test-Path $stderr) { (Get-Item $stderr).Length } else { 0 }
    }
    if ($exitCode -ne $expectedExit) {
        $script:failed = $true
    }
}

function Run-Tool($name, $exe, [string[]]$arguments, $expectedExit = 0) {
    $safe = Safe-Name $name
    $stdout = "$RunDir\$safe.stdout.txt"
    $stderr = "$RunDir\$safe.stderr.txt"
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $argLine = ($arguments | ForEach-Object { Quote-Arg $_ }) -join " "
    $process = Start-Process -FilePath $exe -ArgumentList $argLine -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    $exitCode = if ($null -eq $process.ExitCode) { 0 } else { $process.ExitCode }
    $timer.Stop()
    Add-Result $name $exitCode $expectedExit $stdout $stderr $timer.Elapsed.TotalSeconds
}

function Run-GodotScript($scriptName) {
    Run-Tool -name $scriptName -exe $godot -arguments @("--headless", "--path", $project, "--script", "res://scripts/tools/$scriptName")
}

Run-Tool -name "art_reboot_audit_assets.py" -exe "python" -arguments @("$project\tools\art_reboot_audit_assets.py")
Run-Tool -name "art_reboot_sync_asset_candidates.py" -exe "python" -arguments @("$project\tools\art_reboot_sync_asset_candidates.py")
Run-Tool -name "art_reboot_audit_characters.py" -exe "python" -arguments @("$project\tools\art_reboot_audit_characters.py")
Run-Tool -name "art_reboot_validate_status.py" -exe "python" -arguments @("$project\tools\art_reboot_validate_status.py")
Run-Tool -name "art_reboot_visual_100_gate.py" -exe "python" -arguments @("$project\tools\art_reboot_visual_100_gate.py") -expectedExit 1

Run-GodotScript "import_gamesiam_roster.gd"
"validate_phase3.gd","validate_phase8.gd","validate_phase9.gd","validate_phase10.gd","validate_skill_roster.gd","validate_first_session_fun.gd","export_debug_analytics_csv.gd","run_balance_sim.gd" | ForEach-Object { Run-GodotScript $_ }

$baselineValidators = Get-ChildItem "$project\scripts\tools" -Filter "validate_???_baseline.gd" | Sort-Object Name
if ($baselineValidators.Count -ne 40) {
    throw "Expected 40 baseline validators, found $($baselineValidators.Count)"
}
$baselineValidators | ForEach-Object { Run-GodotScript $_.Name }

$summary = [pscustomobject]@{
    generated_at = (Get-Date).ToString("o")
    run_dir = $RunDir
    ok = -not $failed
    result_count = $results.Count
    baseline_validator_count = $baselineValidators.Count
    results = $results
}
$summaryPath = "$RunDir\baseline_validation_summary.json"
$summary | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $summaryPath

$lines = @(
    "# GAME SIAM IDLE Art Reboot Baseline Validation",
    "",
    "Status: ``$($summary.ok)``",
    "Commands: $($summary.result_count)",
    "Baseline validators: $($summary.baseline_validator_count)",
    "",
    "| Command | Exit | Expected | Stdout bytes | Stderr bytes |",
    "|---|---:|---:|---:|---:|"
)
$results | ForEach-Object {
    $lines += "| $($_.name) | $($_.exit_code) | $($_.expected_exit) | $($_.stdout_bytes) | $($_.stderr_bytes) |"
}
$lines | Set-Content -Encoding UTF8 "$RunDir\baseline_validation_summary.md"

Write-Host "baseline validation summary: $summaryPath"
if ($failed) {
    throw "One or more baseline validation commands failed"
}
