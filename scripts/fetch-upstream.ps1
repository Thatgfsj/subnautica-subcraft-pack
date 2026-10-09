# fetch-upstream.ps1 - clone the pinned SubCraft commit and apply this repo's patches.
#   powershell -ExecutionPolicy Bypass -File scripts\fetch-upstream.ps1 [-Dir upstream-build]
param([string]$Dir = 'upstream-build')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$commit = (Get-Content (Join-Path $root 'patches\UPSTREAM_COMMIT.txt') -Raw).Trim()
$target = Join-Path $root $Dir

if (Test-Path (Join-Path $target '.git')) {
    Write-Host "upstream: reusing $target"
} else {
    Write-Host "upstream: cloning SubCraft (MIT, FumperForrest)"
    git clone https://github.com/FumperForrest/SubCraft $target
}
git -C $target fetch --all --quiet
git -C $target checkout --quiet $commit
git -C $target reset --hard --quiet $commit
git -C $target clean -fd --quiet

foreach ($p in @('host.patch', 'guest.patch')) {
    $file = Join-Path $root "patches\$p"
    Write-Host "patch: applying $p"
    git -C $target apply --whitespace=nowarn $file
}

Write-Host "done: $target is at $commit with this repo's patches applied" -ForegroundColor Green
