[System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.Encoding]::UTF8
Import-Module matrix
Import-Module cowsay
New-Alias ll ls -Force      # ll -> detailed dir listing
function .. { cd .. }                           # Go up one directory
function ... { cd ../.. }                       # Go up two directories
function cl { clear }                           # Clear screen
function rm { remove-item }            # Remove
function home { cd $env:userprofile }
function touch {if((Test-Path -Path ($args[0])) -eq $false) {Set-Content -Path ($args[0]) -Value ($null)} else {(Get-Item ($args[0])).LastWriteTime = Get-Date } }
function rmrf {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path
    )
    Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
}
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}
Invoke-Expression (&starship init powershell)
$Env:KOMOREBI_CONFIG_HOME = '$Env:USERPROFILE/.config/komorebi'