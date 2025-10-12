#!/usr/bin/env bash

# === Colors ===
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
BOLD="\033[1m"
RESET="\033[0m"

# === Paths ===
BASE_DIR="/opt"
DIR_A="${BASE_DIR}/infotainment-A"
DIR_B="${BASE_DIR}/infotainment-B"
SYMLINK="${BASE_DIR}/infotainment"
PENDING_FLAG="${BASE_DIR}/infotainment-pending"
SWAP_SCRIPT="/usr/local/bin/infotainment-swap-on-boot.sh"
SERVICE_FILE="/etc/systemd/system/infotainment-update-swap.service"

# === OS Check ===
if ! grep -qiE "Arch" /etc/os-release; then
    echo -e "${RED}${BOLD}ERROR:${RESET} This script is intended to run on ${YELLOW}Arch Linux${RESET} or Arch-based systems only."
    exit 1
fi

# === Package Manager Check ===
if ! command -v pacman &> /dev/null; then
    echo -e "${RED}${BOLD}ERROR:${RESET} The required package manager ${YELLOW}pacman${RESET} was not found."
    exit 1
fi

# === Root Privilege Check ===
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}${BOLD}ERROR:${RESET} This script must be run as ${YELLOW}root${RESET}."
    echo -e "Try again using: ${CYAN}sudo $0${RESET}"
    exit 1
fi

# === Warning Message ===
echo -e "${RED}${BOLD}=============================================="
echo -e "   WARNING: System Environment Setup Script"
echo -e "==============================================${RESET}"
echo -e "${CYAN}This will fully setup the system environment to run Infotainment software.${RESET}"
echo -e "${YELLOW}This is intended to run in an Arch Linux environment.${RESET}"
echo -e "${RED}${BOLD}NEVER run this on a development build.${RESET}"
echo ""
echo -e "${CYAN}Process will start in 10 seconds...${RESET}"
echo ""

# === Countdown ===
for i in {10..1}; do
    echo -ne "${YELLOW}Starting in ${i}...   \r${RESET}"
    sleep 1
done

echo -e "\n${GREEN}${BOLD}Starting setup now!${RESET}\n"

# === Qt6 Dependencies Installation ===
echo -e "${CYAN}${BOLD}Installing Qt6 dependencies...${RESET}"
QT_PACKAGES=(
    qt6-base
    qt6-tools
    qt6-svg
    qt6-declarative
    qt6-webengine
    qt6-5compat
    qt6-translations
    qt6-location
    qt6-quick3d
)
pacman -Syu --noconfirm
pacman -S --needed --noconfirm "${QT_PACKAGES[@]}"

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}${BOLD}✅ Qt6 dependencies installed successfully!${RESET}"
else
    echo -e "\n${RED}${BOLD}❌ Failed to install some dependencies.${RESET}"
    exit 1
fi

# === Directory Structure Setup ===
echo -e "\n${CYAN}${BOLD}Setting up infotainment directory structure...${RESET}"

mkdir -p "$DIR_A" "$DIR_B"

if [[ -L "$SYMLINK" || -e "$SYMLINK" ]]; then
    rm -f "$SYMLINK"
fi
ln -s "$DIR_A" "$SYMLINK"

chown -R root:root "$DIR_A" "$DIR_B"
chmod -R 755 "$DIR_A" "$DIR_B"

echo -e "${GREEN}${BOLD}✅ Directory structure set:${RESET}"
echo -e "  ${CYAN}$DIR_A${RESET}"
echo -e "  ${CYAN}$DIR_B${RESET}"
echo -e "  ${CYAN}$SYMLINK -> $DIR_A${RESET}"

# === Create Swap Script ===
echo -e "\n${CYAN}${BOLD}Creating swap script...${RESET}"

cat > "$SWAP_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -e

BASE_DIR="/opt"
LINK_PATH="${BASE_DIR}/infotainment"
DIR_A="${BASE_DIR}/infotainment-A"
DIR_B="${BASE_DIR}/infotainment-B"
PENDING_FLAG="${BASE_DIR}/infotainment-pending"

echo "[infotainment-swap] Checking for pending update..."

if [[ -f "$PENDING_FLAG" ]]; then
    echo "[infotainment-swap] Pending update detected — swapping active directory."

    CURRENT_TARGET=$(readlink "$LINK_PATH" || true)

    if [[ "$CURRENT_TARGET" == "$DIR_A" ]]; then
        ln -sfn "$DIR_B" "$LINK_PATH"
        echo "[infotainment-swap] Switched to infotainment-B"
    else
        ln -sfn "$DIR_A" "$LINK_PATH"
        echo "[infotainment-swap] Switched to infotainment-A"
    fi

    rm -f "$PENDING_FLAG"
    echo "[infotainment-swap] Update applied successfully."
else
    echo "[infotainment-swap] No pending update — nothing to do."
fi
EOF

chmod +x "$SWAP_SCRIPT"
echo -e "${GREEN}${BOLD}✅ Swap script created at:${RESET} ${CYAN}$SWAP_SCRIPT${RESET}"

# === Create Systemd Service ===
echo -e "\n${CYAN}${BOLD}Creating systemd service...${RESET}"

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Apply pending infotainment update on boot
DefaultDependencies=no
Before=infotainment.service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=$SWAP_SCRIPT

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable infotainment-update-swap.service

echo -e "${GREEN}${BOLD}✅ Systemd service created and enabled:${RESET} ${CYAN}$SERVICE_FILE${RESET}"
echo -e "Service will run on boot before ${YELLOW}infotainment.service${RESET}."

# === Create New Swap Script with Pending File Logic ===
echo -e "\n${CYAN}${BOLD}Creating new infotainment swap-on-boot script...${RESET}"

# Ensure var lib directory exists for update tracking
mkdir -p /var/lib/infotainment
chmod 755 /var/lib/infotainment

cat > /usr/local/bin/infotainment-swap-on-boot.sh <<'EOF'
#!/usr/bin/env bash
set -e

PENDING_FILE="/var/lib/infotainment/pending-update"
ROLLBACK_FILE="/var/lib/infotainment/rollback-slot"
ACTIVE_SYMLINK="/opt/infotainment"

# Only proceed if there's a pending update
if [ -f "$PENDING_FILE" ]; then
    NEW_SLOT=$(cat "$PENDING_FILE")
    CURRENT_SLOT=$(readlink "$ACTIVE_SYMLINK")

    echo "Pending update found. Switching from $CURRENT_SLOT to $NEW_SLOT"

    # Record rollback slot before switching
    echo "$CURRENT_SLOT" > "$ROLLBACK_FILE"

    # Switch symlink atomically
    ln -sfn "$NEW_SLOT" "$ACTIVE_SYMLINK"

    # Remove the pending file so it doesn't loop forever
    rm "$PENDING_FILE"

    echo "Switched active slot to $NEW_SLOT. App will launch from there."
fi
EOF

chmod +x /usr/local/bin/infotainment-swap-on-boot.sh
echo -e "${GREEN}${BOLD}✅ Swap script created and made executable:${RESET} ${CYAN}/usr/local/bin/infotainment-swap-on-boot.sh${RESET}"

# === Create Rollback Script ===
echo -e "\n${CYAN}${BOLD}Creating rollback script...${RESET}"

cat > /usr/local/bin/infotainment-rollback-if-needed.sh <<'EOF'
#!/usr/bin/env bash
set -e

ROLLBACK_FILE="/var/lib/infotainment/rollback-slot"
ACTIVE_SYMLINK="/opt/infotainment"
MARKER_FILE="/var/lib/infotainment/boot-ok"

# If the boot-ok marker does not exist, previous boot failed
if [ -f "$ROLLBACK_FILE" ] && [ ! -f "$MARKER_FILE" ]; then
    PREVIOUS_SLOT=$(cat "$ROLLBACK_FILE")
    CURRENT_SLOT=$(readlink "$ACTIVE_SYMLINK")

    echo "App did not report healthy on last boot. Rolling back from $CURRENT_SLOT to $PREVIOUS_SLOT"

    ln -sfn "$PREVIOUS_SLOT" "$ACTIVE_SYMLINK"
    rm "$ROLLBACK_FILE"
else
    echo "System healthy or no rollback needed."
fi
EOF

chmod +x /usr/local/bin/infotainment-rollback-if-needed.sh
echo -e "${GREEN}${BOLD}✅ Rollback script created and made executable:${RESET} ${CYAN}/usr/local/bin/infotainment-rollback-if-needed.sh${RESET}"

# === Create Rollback Systemd Service ===
echo -e "\n${CYAN}${BOLD}Creating rollback systemd service...${RESET}"

ROLLBACK_SERVICE_FILE="/etc/systemd/system/infotainment-rollback.service"

cat > "$ROLLBACK_SERVICE_FILE" <<EOF
[Unit]
Description=Rollback to previous slot if infotainment failed last boot
After=local-fs.target
Before=infotainment-update-swap.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/infotainment-rollback-if-needed.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable the rollback service
systemctl daemon-reload
systemctl enable infotainment-rollback.service

echo -e "${GREEN}${BOLD}✅ Rollback service created and enabled:${RESET} ${CYAN}$ROLLBACK_SERVICE_FILE${RESET}"
echo -e "Rollback service will run on boot before infotainment-update-swap.service"

# === Create Clear Marker Systemd Service ===
echo -e "\n${CYAN}${BOLD}Creating clear-marker systemd service...${RESET}"

CLEAR_MARKER_SERVICE_FILE="/etc/systemd/system/infotainment-clear-marker.service"

cat > "$CLEAR_MARKER_SERVICE_FILE" <<EOF
[Unit]
Description=Clear health marker on shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/rm -f /var/lib/infotainment/boot-ok

[Install]
WantedBy=shutdown.target
EOF

# Reload systemd, enable the service
systemctl daemon-reload
systemctl enable infotainment-clear-marker.service

echo -e "${GREEN}${BOLD}✅ Clear-marker service created and enabled:${RESET} ${CYAN}$CLEAR_MARKER_SERVICE_FILE${RESET}"
echo -e "This will remove the health marker on shutdown to allow rollback detection on next boot."

# === Create main Infotainment System systemd service ===
echo -e "\n${CYAN}${BOLD}Creating main infotainment systemd service...${RESET}"

INFOTAINMENT_SERVICE_FILE="/etc/systemd/system/infotainment.service"

cat > "$INFOTAINMENT_SERVICE_FILE" <<EOF
[Unit]
Description=F150 Infotainment System
After=network.target
Wants=network.target
After=local-fs.target

[Service]
Type=simple
ExecStart=/opt/myapp/appInfotainmentSystem
Restart=always
RestartSec=5
Environment=LD_LIBRARY_PATH=/opt/myapp/lib
User=ashton
Group=ashton

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable infotainment.service
systemctl start infotainment.service

echo -e "${GREEN}${BOLD}✅ Main infotainment service created, enabled, and started:${RESET} ${CYAN}$INFOTAINMENT_SERVICE_FILE${RESET}"

# === Function to install latest release from GitHub ===
install_latest_release() {
    echo -e "\n${CYAN}${BOLD}Installing latest release from GitHub...${RESET}"

    # Ensure BASE_DIR exists
    mkdir -p "${DIR_A}"

    # GitHub repo and API URL for latest release
    GITHUB_REPO="AshtonCMiller/F150Infotainment"
    API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

    # Get the latest release .tar.gz URL
    RELEASE_URL=$(curl -s $API_URL | grep "browser_download_url" | grep ".tar.gz" | cut -d '"' -f 4)

    if [[ -z "$RELEASE_URL" ]]; then
        echo -e "${RED}❌ Could not find latest .tar.gz release URL.${RESET}"
        return 1
    fi

    echo "Downloading latest release from: $RELEASE_URL"
    TMP_TAR=$(mktemp /tmp/infotainment-XXXXXX.tar.gz)
    curl -L -o "$TMP_TAR" "$RELEASE_URL"

    echo "Extracting release to ${DIR_A}..."
    # Extract directly into DIR_A, overwrite existing files
    tar -xzf "$TMP_TAR" -C "${DIR_A}" --strip-components=1

    rm -f "$TMP_TAR"

    echo -e "${GREEN}${BOLD}✅ Latest release installed in ${DIR_A}${RESET}"
}

# Call the function at the end of the installer
install_latest_release
echo -e "\n${GREEN}${BOLD}🎉 Installation completed successfully!${RESET}"
echo -e "Reboot to apply update."
# === Done ===
# echo -e "\n${GREEN}${BOLD}🎉 Installation completed successfully!${RESET}"
# echo -e "Next steps:"
# echo -e "  - Place your application build in: ${CYAN}$DIR_B${RESET}"
# echo -e "  - Touch flag file to trigger swap on next boot: ${CYAN}touch $PENDING_FLAG${RESET}"
# echo -e "  - Reboot to apply update."

# curl -o SetupEnvironment.sh "https://raw.githubusercontent.com/AshtonCMiller/F150Infotainment/refs/heads/main/SetupEnvironment.sh" & chmod +x ./SetupEnvironment.sh & ./SetupEnvironment.sh