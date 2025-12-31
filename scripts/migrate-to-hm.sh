#!/usr/bin/env bash
# scripts/migrate-to-hm.sh
#
# Migration script: Arch Linux manual configs → Home Manager
# Run from nix-config directory
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "=============================================="
echo " Home Manager Migration Script"
echo "=============================================="
echo ""
echo "This script will:"
echo "  1. Backup current manual configs"
echo "  2. Remove conflicting manual dotfiles"
echo "  3. Activate Home Manager configuration"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Aborted."
    exit 0
fi

# Step 1: Create backup
log_info "Creating backup directory..."
mkdir -p "$BACKUP_DIR"

# Backup items
BACKUP_ITEMS=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.gitconfig"
    "$HOME/.config/fish"
    "$HOME/.config/helix"
    "$HOME/.config/direnv"
    "$HOME/.ssh/config"
)

for item in "${BACKUP_ITEMS[@]}"; do
    if [[ -e "$item" ]]; then
        dest="$BACKUP_DIR/$(basename "$item")"
        cp -a "$item" "$dest" 2>/dev/null || true
        log_info "Backed up: $item"
    fi
done

log_success "Backup complete: $BACKUP_DIR"

# Step 2: Remove conflicting files
log_info "Removing conflicting manual configs..."

# Files that Home Manager will regenerate
REMOVE_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.gitconfig"
)

for file in "${REMOVE_FILES[@]}"; do
    if [[ -f "$file" && ! -L "$file" ]]; then
        rm -f "$file"
        log_info "Removed: $file"
    fi
done

# Directories that Home Manager will regenerate
REMOVE_DIRS=(
    "$HOME/.config/fish"
    "$HOME/.config/helix"
    "$HOME/.config/direnv"
    "$HOME/.config/git"
)

for dir in "${REMOVE_DIRS[@]}"; do
    if [[ -d "$dir" && ! -L "$dir" ]]; then
        rm -rf "$dir"
        log_info "Removed: $dir"
    fi
done

# Special handling for SSH config (preserve keys, remove config)
if [[ -f "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
    rm -f "$HOME/.ssh/config"
    log_info "Removed: ~/.ssh/config (keys preserved)"
fi

log_success "Conflicting files removed"

# Step 3: Create SSH sockets directory
mkdir -p "$HOME/.ssh/sockets"
log_info "Created SSH sockets directory"

# Step 4: Activate Home Manager
log_info "Activating Home Manager configuration..."
echo ""

if [[ -f "flake.nix" ]]; then
    nix run .#home-switch
    log_success "Home Manager activated!"
else
    log_error "Not in nix-config directory. Run from ~/Repositories/nix-repos/nix-config"
    exit 1
fi

echo ""
echo "=============================================="
echo " Migration Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Start a new shell (fish is now default)"
echo "  2. Verify: echo \$EDITOR (should be 'hx')"
echo "  3. Verify: git config user.email"
echo "  4. Test direnv: cd to a project with .envrc"
echo ""
echo "Backup preserved at: $BACKUP_DIR"
echo "To rollback: home-manager generations && home-manager switch -n"
