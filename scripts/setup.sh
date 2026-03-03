#!/bin/bash
# /digest — Optional dependency installer
# Run specific installations based on arguments:
#   ./setup.sh x-reader    — Install x-reader MCP server
#   ./setup.sh whisper     — Install Whisper + ffmpeg
#   ./setup.sh playwright  — Install Playwright
#   ./setup.sh all         — Install everything

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

install_xreader() {
    echo "Installing x-reader MCP server..."

    if command -v npx &> /dev/null; then
        # Add x-reader to Claude Code MCP settings
        CLAUDE_CONFIG_DIR="$HOME/.claude"
        MCP_CONFIG="$CLAUDE_CONFIG_DIR/settings.json"

        if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
            mkdir -p "$CLAUDE_CONFIG_DIR"
        fi

        echo ""
        echo "To add x-reader MCP to Claude Code, add this to your MCP settings:"
        echo ""
        echo '  "x-reader": {'
        echo '    "command": "npx",'
        echo '    "args": ["-y", "x-reader-mcp"]'
        echo '  }'
        echo ""
        echo "You can do this via: claude mcp add x-reader -- npx -y x-reader-mcp"
        echo ""

        log_success "x-reader setup instructions displayed"
    else
        log_error "Node.js/npx not found. Install Node.js first: https://nodejs.org"
        return 1
    fi
}

install_whisper() {
    echo "Installing Whisper + ffmpeg..."

    # Install ffmpeg
    if command -v ffmpeg &> /dev/null; then
        log_success "ffmpeg already installed"
    elif command -v brew &> /dev/null; then
        echo "Installing ffmpeg via Homebrew..."
        brew install ffmpeg
        log_success "ffmpeg installed"
    elif command -v apt-get &> /dev/null; then
        echo "Installing ffmpeg via apt..."
        sudo apt-get install -y ffmpeg
        log_success "ffmpeg installed"
    else
        log_error "Could not install ffmpeg. Please install manually."
        return 1
    fi

    # Install Whisper
    if command -v whisper &> /dev/null; then
        log_success "Whisper already installed"
    elif command -v pip3 &> /dev/null; then
        echo "Installing openai-whisper via pip..."
        pip3 install openai-whisper
        log_success "Whisper installed"
    elif command -v pip &> /dev/null; then
        echo "Installing openai-whisper via pip..."
        pip install openai-whisper
        log_success "Whisper installed"
    else
        log_error "Python pip not found. Install Python first: https://python.org"
        return 1
    fi
}

install_playwright() {
    echo "Installing Playwright..."

    if command -v pip3 &> /dev/null; then
        pip3 install playwright
        python3 -m playwright install chromium
        log_success "Playwright installed with Chromium"
    elif command -v pip &> /dev/null; then
        pip install playwright
        python -m playwright install chromium
        log_success "Playwright installed with Chromium"
    else
        log_error "Python pip not found. Install Python first: https://python.org"
        return 1
    fi
}

# Main
case "${1:-}" in
    x-reader)
        install_xreader
        ;;
    whisper)
        install_whisper
        ;;
    playwright)
        install_playwright
        ;;
    all)
        install_xreader
        echo ""
        install_whisper
        echo ""
        install_playwright
        ;;
    *)
        echo "Usage: ./setup.sh [x-reader|whisper|playwright|all]"
        echo ""
        echo "  x-reader    — Install x-reader MCP (rich content extraction)"
        echo "  whisper     — Install Whisper + ffmpeg (video transcription)"
        echo "  playwright  — Install Playwright (deep extraction for walled content)"
        echo "  all         — Install everything"
        exit 1
        ;;
esac

echo ""
log_success "Setup complete!"
