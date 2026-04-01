#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/voxcode"
CONFIG_DST="$CONFIG_DIR/config.toml"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   VoxCode — Installer${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# ── Step 1: Prerequisites ──────────────────────────────────────────────
echo -e "${GREEN}[1/4] Checking prerequisites...${NC}"

if ! command -v uv >/dev/null 2>&1; then
    echo -e "${RED}Error: uv is required but not installed.${NC}"
    echo "Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi
echo -e "${GREEN}  ✓ uv $(uv --version 2>/dev/null | awk '{print $2}')${NC}"

if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}Error: python3 is required.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ python3 $(python3 --version 2>&1 | awk '{print $2}')${NC}"

# Check for PortAudio (required by sounddevice)
PORTAUDIO_FOUND=false
if ldconfig -p 2>/dev/null | grep -q libportaudio; then
    PORTAUDIO_FOUND=true
elif [ -f /usr/lib/libportaudio.so ] || [ -f /usr/lib64/libportaudio.so ]; then
    PORTAUDIO_FOUND=true
elif pkg-config --exists portaudio-2.0 2>/dev/null; then
    PORTAUDIO_FOUND=true
fi

if [ "$PORTAUDIO_FOUND" = true ]; then
    echo -e "${GREEN}  ✓ PortAudio found${NC}"
else
    echo -e "${RED}Error: PortAudio library not found (required by sounddevice).${NC}"
    echo ""
    echo "  Install it for your distro:"
    echo "    Ubuntu/Debian:  sudo apt install libportaudio2"
    echo "    Fedora/RHEL:    sudo dnf install portaudio-devel"
    echo "    Arch:           sudo pacman -S portaudio"
    echo ""
    exit 1
fi
echo ""

# ── Step 2: Install as global tool ─────────────────────────────────────
echo -e "${GREEN}[2/4] Installing voxcode as system command...${NC}"

# uv tool install installs the package in an isolated environment
# and makes the `voxcode` command available globally in ~/.local/bin
uv tool install --from "$SCRIPT_DIR" --force --reinstall voxcode 2>&1 | while read -r line; do
    echo "  $line"
done

if command -v voxcode >/dev/null 2>&1; then
    echo -e "${GREEN}  ✓ voxcode installed at $(command -v voxcode)${NC}"
else
    # uv tool puts binaries in ~/.local/bin — ensure it's in PATH
    if [ -f "$HOME/.local/bin/voxcode" ]; then
        echo -e "${YELLOW}  ⚠ Installed at ~/.local/bin/voxcode but not in PATH${NC}"
        echo "  Add to your shell config: export PATH=\"\$HOME/.local/bin:\$PATH\""
    else
        echo -e "${RED}  ✗ Installation failed${NC}"
        exit 1
    fi
fi
echo ""

# ── Step 3: Install config ─────────────────────────────────────────────
echo -e "${GREEN}[3/4] Setting up configuration...${NC}"

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_DST" ]; then
    echo -e "${YELLOW}  Config already exists — keeping current: $CONFIG_DST${NC}"
else
    cp "$SCRIPT_DIR/config.example.toml" "$CONFIG_DST"
    echo -e "${GREEN}  ✓ Installed: $CONFIG_DST${NC}"
    echo -e "${YELLOW}  Edit this file to set your audio device and preferences.${NC}"
fi
echo ""

# ── Step 4: Check audio device ─────────────────────────────────────────
echo -e "${GREEN}[4/4] Audio device check...${NC}"

echo "  Available audio devices:"
voxcode --list-devices 2>/dev/null | while read -r line; do
    echo "    $line"
done || echo -e "${YELLOW}  Could not list devices (GPU/audio driver needed)${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Installation Complete${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo "Command:  $(command -v voxcode 2>/dev/null || echo '~/.local/bin/voxcode')"
echo "Config:   $CONFIG_DST"
echo ""
echo "Usage:"
echo "  voxcode --list-devices              # find your microphone"
echo "  voxcode --audio-device <N>          # start with mic N"
echo "  voxcode --audio-device <N> --mode ptt  # push-to-talk mode"
echo ""
echo "Edit $CONFIG_DST to set defaults."
echo ""
