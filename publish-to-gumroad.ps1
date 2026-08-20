# GLOWELLE - Publish landing page to Gumroad (Windows PowerShell)
# Run this script in the same folder as landing.html
# Usage: Right-click > Run with PowerShell, or: powershell -ExecutionPolicy Bypass -File publish-to-gumroad.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== GLOWELLE Gumroad Publisher ===" -ForegroundColor Green
Write-Host ""

# Check if landing.html exists
$htmlFile = Join-Path $PSScriptRoot "landing.html"
if (-not (Test-Path $htmlFile)) {
    $htmlFile = Join-Path (Get-Location) "landing.html"
}
if (-not (Test-Path $htmlFile)) {
    Write-Host "ERROR: landing.html not found." -ForegroundColor Red
    Write-Host "Make sure this script is in the same folder as landing.html"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found: $htmlFile" -ForegroundColor Cyan

# Configuration
$accessToken = "ccTw6jTEtu8LC8UyAFO5g1Y74utTbShzZVrpaGPAODY"
$productId = "kvoypq"
$apiBase = "https://api.gumroad.com/v2"

# Step 1: Read HTML
Write-Host ""
Write-Host "1/3  Reading landing.html..." -ForegroundColor Yellow
$htmlContent = Get-Content $htmlFile -Raw -Encoding UTF8
Write-Host "     Read $($htmlContent.Length) characters" -ForegroundColor Gray

# Step 2: Publish (PUT custom_html to product)
Write-Host ""
Write-Host "2/3  Publishing to Gumroad..." -ForegroundColor Yellow

$uri = "$apiBase/products/$productId"
$headers = @{
    "Authorization" = "Bearer $accessToken"
}

$body = @{
    custom_html = $htmlContent
}

try {
    $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $body -ContentType "application/x-www-form-urlencoded"

    if ($response.success -eq $true) {
        Write-Host "     Published successfully!" -ForegroundColor Green

        # Show sanitization info if available
        if ($response.sanitization_report) {
            $report = $response.sanitization_report
            if ($report.removed_tags -and $report.removed_tags.Count -gt 0) {
                Write-Host ""
                Write-Host "     Sanitization removed tags: $($report.removed_tags -join ', ')" -ForegroundColor DarkYellow
            }
            if ($report.removed_attributes -and $report.removed_attributes.Count -gt 0) {
                Write-Host "     Sanitization removed attributes: $($report.removed_attributes -join ', ')" -ForegroundColor DarkYellow
            }
        }
    } else {
        Write-Host "     Publish returned unexpected response:" -ForegroundColor Red
        $response | ConvertTo-Json -Depth 5
    }
} catch {
    Write-Host "     ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "     Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 3: Show live URL
Write-Host ""
Write-Host "3/3  Getting live URL..." -ForegroundColor Yellow

try {
    $showResponse = Invoke-RestMethod -Uri "$apiBase/products/$productId" -Method Get -Headers $headers
    $product = $showResponse.product

    $liveUrl = ""
    if ($product.short_url) { $liveUrl = $product.short_url }
    elseif ($product.landing_url) { $liveUrl = $product.landing_url }
    elseif ($product.permalink_url) { $liveUrl = $product.permalink_url }

    Write-Host ""
    Write-Host "=== DONE! ===" -ForegroundColor Green
    Write-Host ""
    if ($liveUrl) {
        Write-Host "Your GLOWELLE landing page is live at:" -ForegroundColor Green
        Write-Host $liveUrl -ForegroundColor Cyan
        Write-Host ""
    }
    Write-Host "Product: $($product.name)" -ForegroundColor Gray
} catch {
    Write-Host "     Could not fetch product URL: $($_.Exception.Message)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "=== DONE! Page was published. ===" -ForegroundColor Green
    Write-Host "Visit your Gumroad dashboard to see the live page." -ForegroundColor Gray
}

Write-Host ""
Read-Host "Press Enter to close"
