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

# ── Root check ────────────────────────────────────────
if [[ "$(whoami)" != "root" ]]; then
  banner
  err "You must run this script as root."
  echo -e "  ${Y}Try: sudo -s${NC}"
  exit 1
fi

# ── OS check ──────────────────────────────────────────
os_version=$(lsb_release -rs 2>/dev/null)
if [[ "$os_version" =~ ^(8|9|10|11|16|18)\. ]]; then
  banner
  err "Incompatible OS: Ubuntu 20.04 or higher is required."
  exit 1
fi

banner
echo -e "${C}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${Y}  Compatible OS detected — starting installation  ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════╝${NC}"
echo ""
sleep 2

# ── Variables ─────────────────────────────────────────
udp_dir='/etc/UDPCustom'
udp_file='/etc/UDPCustom/udp-custom'

# ── Dependencies ──────────────────────────────────────
step "Updating package lists..."
apt-get update -y &>/dev/null
ok "Package list updated"

step "Installing dependencies..."
apt-get install -y wget curl dos2unix &>/dev/null
ok "Dependencies installed"

# ── Clean up previous install ─────────────────────────
step "Cleaning up previous installation..."
systemctl stop udpgw udp-custom &>/dev/null
rm -rf /root/udp
mkdir -p /root/udp
rm -rf "$udp_dir"
mkdir -p "$udp_dir"
touch "$udp_file"
rm -rf /etc/limiter.sh /etc/UDPCustom/limiter.sh \
       /etc/UDPCustom/module /usr/bin/udp \
       /etc/systemd/system/udpgw.service \
       /etc/systemd/system/udp-custom.service
ok "Cleaned up"

# ── Download module ───────────────────────────────────
step "Downloading module..."
wget -O "$udp_dir/module" "${REPO_RAW}/module/module" &>/dev/null \
  && chmod +x "$udp_dir/module" && ok "Module downloaded" \
  || { err "Failed to download module"; exit 1; }

source "$udp_dir/module"

# ── Download binary ───────────────────────────────────
step "Downloading UDP-Custom binary..."
wget -O /root/udp/udp-custom "${REPO_RAW}/bin/udp-custom-linux-amd64" &>/dev/null \
  && chmod +x /root/udp/udp-custom && ok "Binary downloaded" \
  || { err "Failed to download binary"; exit 1; }

# ── Download limiter ──────────────────────────────────
step "Downloading limiter..."
wget -O /etc/limiter.sh "${REPO_RAW}/module/limiter.sh" &>/dev/null
cp /etc/limiter.sh "$udp_dir/"
chmod +x /etc/limiter.sh "$udp_dir/limiter.sh"
ok "Limiter installed"

# ── Download udpgw ────────────────────────────────────
step "Downloading UDPGW..."
wget -O /bin/udpgw "${REPO_RAW}/module/udpgw" &>/dev/null \
  && chmod +x /bin/udpgw && ok "UDPGW installed" \
  || { err "Failed to download udpgw"; exit 1; }

# ── Download services ─────────────────────────────────
step "Installing systemd services..."
wget -O /etc/systemd/system/udpgw.service "${REPO_RAW}/config/udpgw.service" &>/dev/null
wget -O /etc/systemd/system/udp-custom.service "${REPO_RAW}/config/udp-custom.service" &>/dev/null
chmod 640 /etc/systemd/system/udpgw.service
chmod 640 /etc/systemd/system/udp-custom.service
systemctl daemon-reload &>/dev/null
systemctl enable udpgw udp-custom &>/dev/null
systemctl start udpgw udp-custom &>/dev/null
ok "Services started"

# ── Download config ───────────────────────────────────
step "Downloading config..."
wget -O /root/udp/config.json "${REPO_RAW}/config/config.json" &>/dev/null
chmod +x /root/udp/config.json
ok "Config installed"

# ── Install menu command ──────────────────────────────
step "Installing menu command..."
wget -O /usr/bin/udp "${REPO_RAW}/module/udp" &>/dev/null
chmod +x /usr/bin/udp
ok "Menu command installed — type 'udp' to open"

# ── Disable firewall ─────────────────────────────────
step "Disabling firewall..."
ufw disable &>/dev/null
apt-get remove --purge ufw firewalld netfilter-persistent -y &>/dev/null
ok "Firewall disabled"

# ── Done ──────────────────────────────────────────────
echo ""
echo -e "${C}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${G}         ✔  Installation Complete!               ${C}║${NC}"
echo -e "${C}║${W}         Type 'udp' to open the manager          ${C}║${NC}"
echo -e "${C}║${Y}         github.com/lonyibe  |  v${VERSION}           ${C}║${NC}"
echo -e "${C}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Clean up install script
rm -f /home/ubuntu/install.sh /root/install.sh &>/dev/null

read -rp "  Press ENTER to open the menu..." _
udp
