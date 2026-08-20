#!/bin/bash
# GLOWELLE - Publish landing page to Gumroad
# Run this script in the same folder as landing.html

set -e

echo "=== GLOWELLE Gumroad Publisher ==="
echo ""

# Check if landing.html exists
if [ ! -f "./landing.html" ]; then
    echo "ERROR: landing.html not found in current directory."
    echo "Make sure you're in the same folder as the downloaded landing.html"
    exit 1
fi

# Check if gumroad CLI is installed
if ! command -v gumroad &> /dev/null; then
    echo "Installing Gumroad CLI..."
    curl -fsSL https://gumroad.com/install-cli.sh | bash
    echo ""
fi

# Authenticate
export GUMROAD_ACCESS_TOKEN="ccTw6jTEtu8LC8UyAFO5g1Y74utTbShzZVrpaGPAODY"

echo "1/4  Authenticating..."
echo "$GUMROAD_ACCESS_TOKEN" | gumroad auth login --with-token
echo ""

echo "2/4  Previewing (checking sanitization)..."
gumroad products page preview kvoypq ./landing.html --json --no-input --non-interactive
echo ""

echo "3/4  Publishing..."
gumroad products page publish kvoypq ./landing.html --json --no-input --non-interactive
echo ""

echo "4/4  Getting live URL..."
gumroad products page url kvoypq --json --no-input --non-interactive
echo ""

echo "=== DONE! Your GLOWELLE landing page is live ==="
