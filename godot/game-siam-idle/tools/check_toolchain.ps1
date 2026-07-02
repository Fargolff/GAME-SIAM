$ErrorActionPreference = "Stop"

$godot = "C:\Users\ADMIN\AppData\Local\Programs\Godot\4.7-stable\Godot_v4.7-stable_win64.exe"
$jdk = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
$sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$deno = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\DenoLand.Deno_Microsoft.Winget.Source_8wekyb3d8bbwe\deno.exe"
$supabase = Join-Path $env:LOCALAPPDATA "Programs\Supabase\supabase.exe"
$templates = Join-Path $env:APPDATA "Godot\export_templates\4.7.stable"

$env:JAVA_HOME = $jdk
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk
$env:Path = "$jdk\bin;$sdk\cmdline-tools\latest\bin;$sdk\platform-tools;$(Split-Path -Parent $supabase);$env:Path"

$checks = @(
  @{ Name = "Godot"; Path = $godot; Command = { & $godot --headless --version } },
  @{ Name = "Java"; Path = "$jdk\bin\java.exe"; Command = { & java --version | Select-Object -First 1 } },
  @{ Name = "Javac"; Path = "$jdk\bin\javac.exe"; Command = { & javac --version } },
  @{ Name = "Deno"; Path = $deno; Command = { & $deno --version | Select-Object -First 1 } },
  @{ Name = "Supabase"; Path = $supabase; Command = { & $supabase --version } },
  @{ Name = "Sdkmanager"; Path = "$sdk\cmdline-tools\latest\bin\sdkmanager.bat"; Command = { & sdkmanager --version } },
  @{ Name = "ADB"; Path = "$sdk\platform-tools\adb.exe"; Command = { & adb --version | Select-Object -First 1 } },
  @{ Name = "GodotExportTemplates"; Path = "$templates\android_release.apk"; Command = { "4.7.stable templates installed" } },
  @{ Name = "AndroidPlatform"; Path = "$sdk\platforms\android-36.1\android.jar"; Command = { "android-36.1 installed" } },
  @{ Name = "AndroidBuildTools"; Path = "$sdk\build-tools\36.1.0\apksigner.bat"; Command = { "build-tools 36.1.0 installed" } }
)

foreach ($check in $checks) {
  if (-not (Test-Path -LiteralPath $check.Path)) {
    throw "Missing $($check.Name): $($check.Path)"
  }
  $value = & $check.Command
  Write-Output "$($check.Name): $value"
}
