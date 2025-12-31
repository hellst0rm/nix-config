#!/usr/bin/env bash
# scripts/verify-hm.sh
#
# Verify Home Manager migration was successful
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)) || true; }
check_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)) || true; }
check_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)) || true; }

echo "=============================================="
echo " Home Manager Verification"
echo "=============================================="
echo ""

# Check symlinks from Home Manager
echo "=== Managed Files ==="

check_symlink() {
    local path="$1"
    local desc="$2"
    if [[ -L "$path" ]]; then
        if [[ "$(readlink "$path")" == /nix/store/* ]]; then
            check_pass "$desc: symlink to nix store"
        else
            check_warn "$desc: symlink but not to nix store"
        fi
    elif [[ -e "$path" ]]; then
        check_fail "$desc: exists but not a symlink"
    else
        check_fail "$desc: missing"
    fi
}

check_symlink "$HOME/.config/fish/config.fish" "Fish config"
check_symlink "$HOME/.config/helix/config.toml" "Helix config"
check_symlink "$HOME/.config/git/config" "Git config"
check_symlink "$HOME/.ssh/config" "SSH config"

echo ""
echo "=== Environment Variables ==="

check_env() {
    local var="$1"
    local expected="$2"
    local actual="${!var:-}"
    if [[ "$actual" == "$expected" ]]; then
        check_pass "$var = $expected"
    elif [[ -n "$actual" ]]; then
        check_warn "$var = $actual (expected: $expected)"
    else
        check_fail "$var is not set"
    fi
}

# These need a fish shell to be verified properly
# For bash, we check what's in the HM files
if [[ -f "$HOME/.config/fish/config.fish" ]]; then
    check_pass "Fish config exists"
else
    check_fail "Fish config missing"
fi

echo ""
echo "=== Commands Available ==="

check_command() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        local path=$(command -v "$cmd")
        if [[ "$path" == /nix/store/* ]] || [[ "$path" == "$HOME/.nix-profile/"* ]]; then
            check_pass "$cmd: from nix ($path)"
        else
            check_warn "$cmd: exists but not from nix ($path)"
        fi
    else
        check_fail "$cmd: not found"
    fi
}

check_command "eza"
check_command "bat"
check_command "fd"
check_command "rg"
check_command "hx"
check_command "git"
check_command "direnv"
check_command "jq"
check_command "fzf"

echo ""
echo "=== Git Configuration ==="

GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")

if [[ "$GIT_EMAIL" == "roger.navelsaker@gmail.com" ]]; then
    check_pass "Git email: $GIT_EMAIL"
else
    check_fail "Git email: $GIT_EMAIL (expected: roger.navelsaker@gmail.com)"
fi

if [[ "$GIT_NAME" == "RogerNavelsaker" ]] || [[ "$GIT_NAME" == "hellst0rm" ]]; then
    check_pass "Git name: $GIT_NAME"
else
    check_fail "Git name: $GIT_NAME (expected: RogerNavelsaker or hellst0rm)"
fi

if git config --global core.pager | grep -q delta; then
    check_pass "Git pager: delta"
else
    check_warn "Git pager: not delta"
fi

echo ""
echo "=== Direnv ==="

if [[ -f "$HOME/.config/direnv/direnv.toml" ]] || [[ -L "$HOME/.config/direnv/direnv.toml" ]]; then
    check_pass "Direnv config exists"
else
    check_fail "Direnv config missing"
fi

if direnv version &>/dev/null; then
    check_pass "Direnv version: $(direnv version)"
else
    check_fail "Direnv not working"
fi

echo ""
echo "=== Home Manager State ==="

if [[ -d "$HOME/.local/state/home-manager" ]]; then
    check_pass "Home Manager state directory exists"
    GEN_COUNT=$(home-manager generations 2>/dev/null | wc -l || echo 0)
    check_pass "Generations available: $GEN_COUNT"
else
    check_fail "Home Manager state directory missing"
fi

echo ""
echo "=============================================="
echo " Summary"
echo "=============================================="
echo ""
echo -e "  ${GREEN}PASS:${NC} $PASS"
echo -e "  ${YELLOW}WARN:${NC} $WARN"
echo -e "  ${RED}FAIL:${NC} $FAIL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}Migration verified successfully!${NC}"
    exit 0
elif [[ $FAIL -lt 3 ]]; then
    echo -e "${YELLOW}Minor issues detected. Review warnings above.${NC}"
    exit 0
else
    echo -e "${RED}Migration has issues. Review failures above.${NC}"
    exit 1
fi
