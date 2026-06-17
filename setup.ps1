# MTSE workspace setup
# Clones (or pulls) the four sub-repositories that make up the MTSE platform.
#
# Usage:
#   1. Clone the root repo once:  git clone https://github.com/Ramkrishna2558/mtse.git
#   2. cd into it and run:         ./setup.ps1
#
# Re-running is safe: existing repos are updated with `git pull`, missing ones are cloned.

$ErrorActionPreference = "Stop"

# repo URL | target path (relative to this script) | branch
$repos = @(
    @{ Url = "https://github.com/Ramkrishna2558/mtse-backend.git";        Path = "mtse-backend/beplayground"; Branch = "feature/config-driven-demo" },
    @{ Url = "https://github.com/Ramkrishna2558/mtse-frontend-admin.git";  Path = "mtse-frontend-admin";       Branch = "feature/mvp" },
    @{ Url = "https://github.com/Ramkrishna2558/mtse-frontend-store.git";  Path = "mtse-frontend-store";       Branch = "feature-footer-redesign" },
    @{ Url = "https://github.com/Ramkrishna2558/mtse-shared.git";          Path = "mtse-shared";               Branch = "feature/mvc" }
)

$root = $PSScriptRoot

foreach ($repo in $repos) {
    $target = Join-Path $root $repo.Path

    if (Test-Path (Join-Path $target ".git")) {
        Write-Host "==> Updating $($repo.Path) ($($repo.Branch))" -ForegroundColor Cyan
        Push-Location $target
        git fetch origin
        git checkout $repo.Branch
        git pull origin $repo.Branch
        Pop-Location
    }
    else {
        Write-Host "==> Cloning $($repo.Url) -> $($repo.Path) ($($repo.Branch))" -ForegroundColor Green
        $parent = Split-Path $target -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        git clone --branch $repo.Branch $repo.Url $target
    }
}

Write-Host "`nAll repositories are in place." -ForegroundColor Green
Write-Host "Next: run 'npm run install:all' to install dependencies, then 'npm start'." -ForegroundColor Yellow
