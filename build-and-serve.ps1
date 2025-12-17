# build-and-serve.ps1

param(
    [switch]$SkipBuild  # Use -SkipBuild to just serve without rebuilding
)

$port = 8000

# Kill any existing Python server on this port
Get-Process -Name python* -ErrorAction SilentlyContinue | 
    Where-Object { $_.CommandLine -match "http.server.*$port" } | 
    Stop-Process -Force -ErrorAction SilentlyContinue

if (-not $SkipBuild) {
    Write-Host "Building site with Pandoc..." -ForegroundColor Cyan
    
    docker run --rm -v "${PWD}:/data" -w /data pandoc/core:3.2 `
        --standalone `
        --from commonmark_x+alerts `
        --output=website/index.html `
        --template=pandoc/template.html4 `
        --css=style.css `
        --toc `
        --toc-depth=1 `
        --resource-path=. `
        --lua-filter=pandoc/diagram.lua `
        --lua-filter=pandoc/paper.lua `
        --lua-filter=pandoc/date.lua `
        --extract-media=website `
        src/index.md

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
    Write-Host "Build complete!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting server on port $port..." -ForegroundColor Cyan
Write-Host ""
Write-Host "=== URLs ===" -ForegroundColor Yellow
Write-Host "  Main site:    http://localhost:$port" -ForegroundColor White
Write-Host "  Charts:       http://localhost:$port/charts/" -ForegroundColor White
Write-Host "  Architecture: http://localhost:$port/charts/architecture.html" -ForegroundColor White
Write-Host "  GIS Adoption: http://localhost:$port/charts/gis-adoption.html" -ForegroundColor White
Write-Host "  Timeline:     http://localhost:$port/charts/timeline.html" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop (may need to press twice)" -ForegroundColor DarkGray
Write-Host ""

Set-Location website
try {
    python -m http.server $port
} finally {
    Set-Location ..
}