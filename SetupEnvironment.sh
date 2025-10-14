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
    xorg
    xorg-xinit
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

########################################
# ✅ Setup autologin for user 'ashton'
########################################
echo "[INFO] Setting up auto-login for user 'ashton'..."

# 1. Ensure the user 'ashton' exists
if ! id "ashton" &>/dev/null; then
    echo "[INFO] Creating user 'ashton'..."
    useradd -m -s /bin/bash ashton
    echo "ashton:password" | chpasswd
    usermod -aG sudo ashton
fi

# 2. Ensure PAM + shadow are installed (required for agetty autologin)
pacman -S --noconfirm pambase shadow util-linux

# 3. Ensure correct PAM login file exists
if [ ! -f /etc/pam.d/login ]; then
    echo "[INFO] Restoring default /etc/pam.d/login..."
    cat <<'EOF' >/etc/pam.d/login
#%PAM-1.0
auth       required   pam_securetty.so
auth       requisite  pam_nologin.so
auth       include    system-local-login
account    include    system-local-login
session    include    system-local-login
EOF
fi

# 4. Get path to agetty
AGETTY_PATH=$(command -v agetty)

# 5. Create override directory for getty@tty1
mkdir -p /etc/systemd/system/getty@tty1.service.d

# 6. Create autologin override file
cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Unit]
After=systemd-user-sessions.service

[Service]
ExecStart=
ExecStart=-${AGETTY_PATH} --autologin ashton --noclear %I \$TERM
Type=simple
EOF

# 7. Reload systemd and enable the service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable getty@tty1.service

echo "[INFO] ✅ Auto-login configured for user 'ashton' on TTY1."

########################################
# ✅ Ensure 'ashton' is in the video group
########################################
echo "[INFO] Adding user 'ashton' to video group for X11 access..."

# Create the video group if it doesn't exist
if ! getent group video >/dev/null; then
    groupadd video
fi

# Add 'ashton' to video group if not already a member
if id -nG "ashton" | grep -qw "video"; then
    echo "[INFO] User 'ashton' is already in the video group."
else
    usermod -aG video ashton
    echo "[INFO] User 'ashton' added to video group."
fi

########################################
# ✅ Configure auto-login to launch infotainment app
########################################
echo "[INFO] Configuring auto-login to launch X and infotainment app for 'ashton'..."

# Create .xinitrc in ashton's home
XINITRC="/home/ashton/.xinitrc"
cat >/home/ashton/.xinitrc <<'EOF'
#!/usr/bin/env bash

# Optional: disable DPMS / screen blanking
xset -dpms
xset s off
xset s noblank

xsetroot -cursor-name left_ptr

# Launch the infotainment app
/opt/infotainment/appInfotainmentSystem
EOF

chown ashton:ashton "$XINITRC"
chmod +x "$XINITRC"

# Modify .bash_profile to automatically run xinit for this user on TTY1
BASH_PROFILE="/home/ashton/.bash_profile"
if ! grep -q "xinit" "$BASH_PROFILE" 2>/dev/null; then
    cat >> "$BASH_PROFILE" <<'EOF'

# Auto-start X and infotainment on login
if [[ -z "$DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
    startx
    #exec /usr/bin/xinit
fi
EOF
fi

echo "[INFO] ✅ Auto-login for 'ashton' will now start X and the infotainment app."


# === Create startx file ===
echo -e "\n${CYAN}${BOLD}Creating X11 window starter...${RESET}"
cat > "/home/ashton/.xinitrc" << EOF
#!/bin/sh

# Disable screen blanking
xset s off
xset -dpms

# set background to black
xsetroot -solid black

# Clear old logs
rm -rf ~/applog.log

# Start logging everything
exec > >(tee -a "./applog.log") 2>&1
echo "=== X session started at $(date) ==="

# Your commands
/opt/infotainment/appInfotainmentSystem

echo "=== X session ended at $(date) ==="

# if it exits, end X so it will restart.
exit 0

EOF

# === Create main Infotainment System systemd service ===
echo -e "\n${CYAN}${BOLD}Creating main infotainment systemd service...${RESET}"

INFOTAINMENT_SERVICE_FILE="/etc/systemd/system/infotainment.service"

cat > "$INFOTAINMENT_SERVICE_FILE" <<EOF
[Unit]
Description=F150 Infotainment System (X11 + App)
After=getty@tty1.service
Requires=getty@tty1.service

[Service]
User=ashton
Type=simple
WorkingDirectory=/home/ashton
ExecStart=/usr/bin/startx -- -nocursor
StandardInput=tty
StandardOutput=journal
Restart=always
RestartSec=5
TTYPath=/dev/tty1
ENVIRONMENT=REAL_HARDWARE=1

[Install]
WantedBy=graphical.target
EOF


# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable infotainment.service
# systemctl start infotainment.service

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

sudo chown -R ashton:ashton /opt
sudo chown -R ashton:ashton /var/lib/infotainment

echo -e "\n${GREEN}${BOLD}🎉 Installation completed successfully!${RESET}"
echo -e "Reboot to apply update."
# === Done ===
# echo -e "\n${GREEN}${BOLD}🎉 Installation completed successfully!${RESET}"
# echo -e "Next steps:"
# echo -e "  - Place your application build in: ${CYAN}$DIR_B${RESET}"
# echo -e "  - Touch flag file to trigger swap on next boot: ${CYAN}touch $PENDING_FLAG${RESET}"
# echo -e "  - Reboot to apply update."

# curl -o ./SetupEnvironment.sh "https://raw.githubusercontent.com/AshtonCMiller/F150Infotainment/refs/heads/main/SetupEnvironment.sh" & chmod +x ./SetupEnvironment.sh & sudo ./SetupEnvironment.sh

# sudo sh -c "$(curl https://raw.githubusercontent.com/AshtonCMiller/F150Infotainment/refs/heads/main/SetupEnvironment.sh)"


# Need to:
# setup infotainment.service in
# /home/ashton/.config/systemd/user/infotainment.service
# with the following:
# [Unit]
# Description=F150 Infotainment X App
# After=graphical.target

# [Service]
# Type=simple
# ExecStart=/usr/bin/xinit /home/ashton/.xinitrc -- :0 vt1 -nolisten tcp
# Restart=always
# Environment=DISPLAY=:0
# User=ashton
# WorkingDirectory=/home/ashton

# [Install]
# WantedBy=default.target

# Then, run
# loginctl enable-linger ashton
# sudo -u ashton systemctl daemon-reload
# sudo -u ashton systemctl enable infotainment.service

# Ensure .Xauthority and .xinitrc exist

# And finally, disable the default infotainment.service


# Need to chown -R ashton:ashton /var/lib/infotainment & /opt