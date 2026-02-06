#!/bin/bash

# ==========================================
#  MASTER KEYMAP
# ==========================================

# 1. Install dependencies for Copy/Paste remapping
echo "Installing xdotool (required for Universal Copy/Paste)..."
sudo apt install -y xdotool

# 2. Backup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="keys_backup_${TIMESTAMP}.dconf"
echo "Backup saved to: $BACKUP_FILE"
dconf dump /org/cinnamon/desktop/keybindings/ >"$BACKUP_FILE"

echo "Applying Master Keybindings..."

# --- 1. WINDOW MANAGEMENT (PRESERVED & UPDATED) ---

# Close = Super + Q
gsettings set org.cinnamon.desktop.keybindings.wm close "['<Super>q']"

# Maximize = Super + F
gsettings set org.cinnamon.desktop.keybindings.wm maximize "['<Super>f']"

# Unmaximize = Super + Alt + F
# (Changed from Shift+F because Omarchy uses Shift+F for Files)
gsettings set org.cinnamon.desktop.keybindings.wm unmaximize "['<Super><Alt>f']"

# Minimize = Super + Comma
gsettings set org.cinnamon.desktop.keybindings.wm minimize "['<Super>comma']"

# Pin (Always on Top) = Super + P (RESTORED)
gsettings set org.cinnamon.desktop.keybindings.wm toggle-always-on-top "['<Super>p']"

# Tiling = Super + Arrows
gsettings set org.cinnamon.desktop.keybindings.wm push-tile-left "['<Super>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm push-tile-right "['<Super>Right']"
gsettings set org.cinnamon.desktop.keybindings.wm push-tile-up "['<Super>Up']"
gsettings set org.cinnamon.desktop.keybindings.wm push-tile-down "['<Super>Down']"

# Resize Window = Super + Alt + Arrows (RESTORED)
gsettings set org.cinnamon.desktop.keybindings.wm resize-window-left "['<Super><Alt>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm resize-window-right "['<Super><Alt>Right']"
gsettings set org.cinnamon.desktop.keybindings.wm resize-window-up "['<Super><Alt>Up']"
gsettings set org.cinnamon.desktop.keybindings.wm resize-window-down "['<Super><Alt>Down']"

# --- 2. WORKSPACE & NAVIGATION (PRESERVED) ---

# Switch Workspace = Super + 1/2/3/4
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-1 "['<Super>1']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-2 "['<Super>2']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-3 "['<Super>3']"
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-4 "['<Super>4']"

# Move Window to Workspace = Super + Shift + 1/2/3/4
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-1 "['<Super><Shift>1']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-2 "['<Super><Shift>2']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-3 "['<Super><Shift>3']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-workspace-4 "['<Super><Shift>4']"

# Cycle Workspaces = Super + Tab
gsettings set org.cinnamon.desktop.keybindings.wm switch-to-workspace-right "['<Super>Tab']"

# Overview (Mission Control) = Super + A (RESTORED)
# Note: Omarchy uses Shift+A for ChatGPT, so Super+A is safe.
gsettings set org.cinnamon.desktop.keybindings.wm expo "['<Super>a']"

# --- 3. APPLICATIONS (HYBRID: OMARCHY + LEGACY) ---

# Terminal = Super + Return
gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "['<Super>Return']"

# File Manager = Super + Shift + F (Omarchy) AND Super + E (Legacy)
gsettings set org.cinnamon.desktop.keybindings.media-keys home "['<Super><Shift>f', '<Super>e']"

# Browser = Super + Shift + B (Omarchy) AND Super + B (Legacy)
gsettings set org.cinnamon.desktop.keybindings.media-keys www "['<Super><Shift>b', '<Super>b']"

# Email = Super + Shift + E
gsettings set org.cinnamon.desktop.keybindings.media-keys email "['<Super><Shift>e']"

# Music/Spotify = Super + Shift + M
gsettings set org.cinnamon.desktop.keybindings.media-keys media "['<Super><Shift>m']"

# Calculator = Super + Shift + C
gsettings set org.cinnamon.desktop.keybindings.media-keys calculator "['<Super><Shift>c']"

# Screenshot (Area) = Super + Shift + S
gsettings set org.cinnamon.desktop.keybindings.media-keys area-screenshot "['<Super><Shift>s']"

# --- 4. SYSTEM & EXTRAS (PRESERVED) ---

# Lock Screen = Super + Escape
gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>Escape']"

# Shutdown/Logout = Super + Shift + Q
gsettings set org.cinnamon.desktop.session quit "['<Super><Shift>q']"

# Restart Cinnamon = Super + Shift + R (RESTORED)
gsettings set org.cinnamon.desktop.keybindings.wm restart-cinnamon "['<Super><Shift>r']"

# System Monitor = Super + Alt + M
# (Changed from Shift+M because Omarchy uses Shift+M for Music)
gsettings set org.cinnamon.desktop.keybindings.media-keys system-monitor "['<Super><Alt>m']"

# Multi-Monitor Move = Super + Shift + Arrows (RESTORED)
gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-left "['<Super><Shift>Left']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-right "['<Super><Shift>Right']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-up "['<Super><Shift>Up']"
gsettings set org.cinnamon.desktop.keybindings.wm move-to-monitor-down "['<Super><Shift>Down']"

# --- 5. CLEANUP ---
gsettings set org.cinnamon.muffin overlay-key "''"
gsettings set org.cinnamon.desktop.keybindings.wm panel-main-menu "[]"

echo "---------------------------------------------------"
echo "DONE! Master Keymap Applied."
echo "Backup saved as: $BACKUP_FILE"
echo "---------------------------------------------------"
echo "MANUAL SETUP REQUIRED (Omarchy Custom Shortcuts):"
echo "Go to System Settings -> Keyboard -> Shortcuts -> Custom Shortcuts"
echo ""
echo "1. Universal Copy (Omarchy Style)"
echo "   - Command: sh -c 'xdotool key --clearmodifiers ctrl+c'"
echo "   - Key: Super + C"
echo ""
echo "2. Universal Paste (Omarchy Style)"
echo "   - Command: sh -c 'xdotool key --clearmodifiers shift+insert'"
echo "   - Key: Super + V"
echo ""
echo "3. Web Apps & Docker (Omarchy Style)"
echo "   - ChatGPT: Super + Shift + A"
echo "   - YouTube: Super + Shift + Y"
echo "   - Lazydocker: Super + Shift + D (Command: alacritty -e lazydocker)"
echo "---------------------------------------------------"

# # Fix "Super + Number" Conflict (Crucial)
# By default, the Mint taskbar intercepts Super+1, Super+2, etc., preventing you from switching workspaces. You must disable this.
# Right-click anywhere on your bottom panel (Taskbar).
# Select Applets.
# Find Grouped Window List (it should have a green checkmark).
# Click the Gear Icon (Configure) on the right.
# Uncheck / Disable the option:
# "Enable Super+<number> shortcut to cycle through windows"
# (Note: This might be under a 'General' or 'Configuration' tab depending on your Mint version).