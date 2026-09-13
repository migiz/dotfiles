param([Parameter(Mandatory=$true)][string]$SourceDirectory)
$ErrorActionPreference = 'Stop'
$fontSource = $SourceDirectory
$fontDirectory = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$fontRegistry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -ItemType Directory -Force -Path $fontDirectory | Out-Null
New-Item -Force -Path $fontRegistry | Out-Null
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class PreviewFontInstall {
    [DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
    public static extern int AddFontResourceEx(string file, uint flags, IntPtr reserved);
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr window, uint message, UIntPtr wparam, IntPtr lparam, uint flags, uint timeout, out UIntPtr result);
}
'@
Get-ChildItem -Path $fontSource -Filter '*.ttf' | ForEach-Object {
    $fontTarget = Join-Path $fontDirectory $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $fontTarget -Force
    $registryName = $_.BaseName + ' (TrueType)'
    New-ItemProperty -Path $fontRegistry -Name $registryName -Value $fontTarget -PropertyType String -Force | Out-Null
    $loaded = [PreviewFontInstall]::AddFontResourceEx($fontTarget, 0, [IntPtr]::Zero)
    if ($loaded -eq 0) { throw "Windows did not load $fontTarget" }
    Write-Output "Installed $($_.Name)"
}
$fontBroadcastResult = [UIntPtr]::Zero
[PreviewFontInstall]::SendMessageTimeout([IntPtr]0xffff, 0x001d, [UIntPtr]::Zero, [IntPtr]::Zero, 2, 5000, [ref]$fontBroadcastResult) | Out-Null
Add-Type -AssemblyName System.Drawing
$fontCollection = New-Object System.Drawing.Text.InstalledFontCollection
$matchingFont = $fontCollection.Families | Where-Object { $_.Name -eq 'JetBrains NF Heavy Icons' }
if (-not $matchingFont) { throw 'Installed family was not found by Windows font enumeration' }
Write-Output "Verified Windows font family: $($matchingFont.Name)"
