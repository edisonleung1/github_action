#!/bin/bash

set -e

# === CONFIGURATION ===
USERNAME="k8s-admin"
SSH_COPY_FROM_USER="root"  # Set to "" to skip SSH key setup

# === CREATE USER ===
echo "🔧 Creating user: $USERNAME"
if id "$USERNAME" &>/dev/null; then
  echo "⚠️ User '$USERNAME' already exists. Skipping creation."
else
  sudo useradd -m -s /bin/bash "$USERNAME"
  echo "✅ User '$USERNAME' created."
fi

# === ADD TO WHEEL GROUP ===
echo "👥 Adding user '$USERNAME' to wheel group for sudo"
sudo usermod -aG wheel "$USERNAME"

# === SETUP PASSWORDLESS SUDO ===
SUDO_FILE="/etc/sudoers.d/$USERNAME"
echo "🔐 Configuring passwordless sudo for '$USERNAME'"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee "$SUDO_FILE" >/dev/null
sudo chmod 440 "$SUDO_FILE"
echo "✅ Passwordless sudo configured"

# === (OPTIONAL) SETUP SSH ACCESS ===
if [ -n "$SSH_COPY_FROM_USER" ]; then
  echo "🔑 Setting up SSH access for '$USERNAME' using keys from '$SSH_COPY_FROM_USER'"
  sudo mkdir -p "/home/$USERNAME/.ssh"
  sudo cp "/home/$SSH_COPY_FROM_USER/.ssh/authorized_keys" "/home/$USERNAME/.ssh/"
  sudo chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
  sudo chmod 700 "/home/$USERNAME/.ssh"
  sudo chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
  echo "✅ SSH key setup complete"
else
  echo "ℹ️ SSH key setup skipped"
fi

echo "🎉 All done! Function account '$USERNAME' is ready for Kubernetes setup."
