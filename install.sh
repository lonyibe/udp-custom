#!/bin/bash
# ╔══════════════════════════════════════════════════════╗
# ║          UDP Custom Manager — by LonyiDev            ║
# ║            Version: 0.0.1  |  2026                  ║
# ║          github.com/lonyibe                          ║
# ╚══════════════════════════════════════════════════════╝

VERSION="0.0.1"
REPO_RAW="https://raw.githubusercontent.com/lonyibe/udp-custom/main"

# ── Colors ────────────────────────────────────────────
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'
C='\033[1;36m'; W='\033[1;97m'; NC='\033[0m'

banner() {
  clear
  echo -e "${C}"
  echo "  ██╗      ██████╗ ███╗  ██╗██╗   ██╗██╗"
  echo "  ██║     ██╔═══██╗████╗ ██║╚██╗ ██╔╝██║"
  echo "  ██║     ██║   ██║██╔██╗██║ ╚████╔╝ ██║"
  echo "  ██║     ██║   ██║██║╚████║  ╚██╔╝  ██║"
  echo "  ███████╗╚██████╔╝██║ ╚███║   ██║   ██║"
  echo "  ╚══════╝ ╚═════╝ ╚═╝  ╚══╝   ╚═╝   ╚═╝"
  echo -e "${NC}\033[0;36m           D E V  ·  U D P  C U S T O M"
  echo -e "${W}         Version ${VERSION}  |  github.com/lonyibe${NC}"
  echo ""
}

step() { echo -e "  ${C}▸${NC} ${W}$1${NC}"; }
ok()   { echo -e "  ${G}✔${NC} $1"; }
err()  { echo -e "  ${R}✗${NC} $1"; }
warn() { echo -e "  ${Y}⚠${NC} $1"; }

# ══════════════════════════════════════════════════════
#  ROOT CHECK
# ══════════════════════════════════════════════════════
if [[ "$(whoami)" != "root" ]]; then
  banner
  err "You must run this script as root."
  echo -e "  ${Y}Try: sudo -s${NC}"
  exit 1
fi

# ══════════════════════════════════════════════════════
#  OS DETECTION
# ══════════════════════════════════════════════════════
detect_os() {
  OS_NAME=""
  OS_VER=""
  OS_VER_MAJOR=""

  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_NAME="${ID,,}"
    OS_VER="$VERSION_ID"
    OS_VER_MAJOR="${VERSION_ID%%.*}"
  elif command -v lsb_release &>/dev/null; then
    OS_NAME=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    OS_VER=$(lsb_release -sr)
    OS_VER_MAJOR="${OS_VER%%.*}"
  elif [[ -f /etc/issue ]]; then
    OS_NAME=$(awk '{print tolower($1)}' /etc/issue | head -1)
    OS_VER=$(grep -oE '[0-9]+\.[0-9]+' /etc/issue | head -1)
    OS_VER_MAJOR="${OS_VER%%.*}"
  else
    OS_NAME="unknown"
    OS_VER="0"
    OS_VER_MAJOR="0"
  fi
}

detect_os
banner

echo -e "${C}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${W}  Detected OS : ${Y}${OS_NAME^} ${OS_VER}${NC}"

# ── Compatibility check ───────────────────────────────
# Supported: Ubuntu/Debian 16.04+ with systemd
SUPPORTED=1
WARN_MSG=""

case "$OS_NAME" in
  ubuntu|debian|linuxmint|pop)
    if [[ "$OS_VER_MAJOR" -lt 16 ]] 2>/dev/null; then
      SUPPORTED=0
    fi
    ;;
  *)
    WARN_MSG="Non-Ubuntu OS detected — compatibility not guaranteed."
    ;;
esac

# Check systemd
if ! pidof systemd &>/dev/null && ! systemctl --version &>/dev/null; then
  SUPPORTED=0
  echo -e "${C}║${R}  ✗ systemd not found — required for services       ${C}║${NC}"
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" ]]; then
  echo -e "${C}║${Y}  ⚠ Arch: ${ARCH} — binary is amd64, may not work    ${C}║${NC}"
fi

if [[ $SUPPORTED -eq 0 ]]; then
  echo -e "${C}║${R}  ✗ Ubuntu 16.04+ with systemd is required           ${C}║${NC}"
  echo -e "${C}╚══════════════════════════════════════════════════╝${NC}"
  exit 1
fi

[[ -n "$WARN_MSG" ]] && echo -e "${C}║${Y}  ⚠ ${WARN_MSG}${NC}"
echo -e "${C}║${G}  ✔ Compatible — starting installation             ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════╝${NC}"
echo ""
sleep 1

# ══════════════════════════════════════════════════════
#  VARIABLES
# ══════════════════════════════════════════════════════
udp_dir='/etc/UDPCustom'
udp_file='/etc/UDPCustom/udp-custom'

# ══════════════════════════════════════════════════════
#  PACKAGE MANAGER DETECTION
# ══════════════════════════════════════════════════════
if command -v apt-get &>/dev/null; then
  PKG_MGR="apt-get"
elif command -v apt &>/dev/null; then
  PKG_MGR="apt"
else
  err "No compatible package manager found (apt required)."
  exit 1
fi

# ══════════════════════════════════════════════════════
#  DEPENDENCIES
# ══════════════════════════════════════════════════════
step "Updating package lists..."
$PKG_MGR update -y &>/dev/null
ok "Package list updated"

step "Installing dependencies..."
PKGS="wget curl openssl at iproute2 procps"

# dos2unix: may be called differently
$PKG_MGR install -y $PKGS &>/dev/null
$PKG_MGR install -y dos2unix &>/dev/null || \
  $PKG_MGR install -y tofrodos &>/dev/null || true

# net-tools for older systems (netstat)
$PKG_MGR install -y net-tools &>/dev/null || true

# atd for scheduling (limiter)
systemctl enable atd &>/dev/null && systemctl start atd &>/dev/null || true
service atd start &>/dev/null || true

ok "Dependencies installed"

# ══════════════════════════════════════════════════════
#  CLEAN UP PREVIOUS INSTALL
# ══════════════════════════════════════════════════════
step "Cleaning up previous installation..."
systemctl stop udpgw udp-custom &>/dev/null
rm -rf /root/udp && mkdir -p /root/udp
rm -rf "$udp_dir"  && mkdir -p "$udp_dir"
touch "$udp_file"
rm -rf /etc/limiter.sh /etc/UDPCustom/limiter.sh \
       /etc/UDPCustom/module /usr/bin/udp \
       /etc/systemd/system/udpgw.service \
       /etc/systemd/system/udp-custom.service
ok "Cleaned up"

# ══════════════════════════════════════════════════════
#  DOWNLOAD FILES
# ══════════════════════════════════════════════════════

# Helper: try wget then curl
dl() {
  local url="$1" dest="$2"
  wget -q --timeout=15 -O "$dest" "$url" 2>/dev/null \
    || curl -sSL --max-time 15 -o "$dest" "$url" 2>/dev/null
}

step "Downloading module..."
dl "${REPO_RAW}/module/module" "$udp_dir/module" \
  && chmod +x "$udp_dir/module" && ok "Module downloaded" \
  || { err "Failed to download module"; exit 1; }

source "$udp_dir/module"

step "Downloading UDP-Custom binary..."
dl "${REPO_RAW}/bin/udp-custom-linux-amd64" "/root/udp/udp-custom" \
  && chmod +x /root/udp/udp-custom && ok "Binary downloaded" \
  || { err "Failed to download binary"; exit 1; }

step "Downloading limiter..."
dl "${REPO_RAW}/module/limiter.sh" "/etc/limiter.sh"
cp /etc/limiter.sh "$udp_dir/"
chmod +x /etc/limiter.sh "$udp_dir/limiter.sh"
ok "Limiter installed"

step "Downloading UDPGW..."
dl "${REPO_RAW}/module/udpgw" "/bin/udpgw" \
  && chmod +x /bin/udpgw && ok "UDPGW installed" \
  || { err "Failed to download udpgw"; exit 1; }

step "Installing systemd services..."
dl "${REPO_RAW}/config/udpgw.service"      "/etc/systemd/system/udpgw.service"
dl "${REPO_RAW}/config/udp-custom.service" "/etc/systemd/system/udp-custom.service"
chmod 640 /etc/systemd/system/udpgw.service
chmod 640 /etc/systemd/system/udp-custom.service
systemctl daemon-reload &>/dev/null
systemctl enable udpgw udp-custom &>/dev/null
systemctl start  udpgw udp-custom &>/dev/null
ok "Services started"

step "Downloading config..."
dl "${REPO_RAW}/config/config.json" "/root/udp/config.json"
ok "Config installed"

step "Installing menu command (udp)..."
dl "${REPO_RAW}/module/udp" "/usr/bin/udp" \
  && chmod +x /usr/bin/udp && ok "Type 'udp' to open the manager" \
  || { err "Failed to install menu"; exit 1; }

# ══════════════════════════════════════════════════════
#  FIREWALL — disable if present
# ══════════════════════════════════════════════════════
step "Disabling firewall..."
ufw disable &>/dev/null || true
$PKG_MGR remove --purge -y ufw firewalld netfilter-persistent &>/dev/null || true
ok "Firewall disabled"

# ══════════════════════════════════════════════════════
#  DONE
# ══════════════════════════════════════════════════════
echo ""
echo -e "${C}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${G}         ✔  Installation Complete!               ${C}║${NC}"
echo -e "${C}║${W}         Type 'udp' to open the manager          ${C}║${NC}"
echo -e "${C}║${Y}         github.com/lonyibe  |  v${VERSION}           ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════╝${NC}"
echo ""

rm -f /home/ubuntu/install.sh /root/install.sh &>/dev/null
read -rp "  Press ENTER to open the menu..." _
udp
