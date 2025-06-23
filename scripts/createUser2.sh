#!/bin/bash

set -e

# === CONFIGURATION ===
USERNAME="k8s-admin"
KEY_NAME="id_rsa_k8s"

# === CREATE USER ===
echo "🔧 Creating user: $USERNAME"
if id "$USERNAME" &>/dev/null; then
  echo "⚠️ User '$USERNAME' already exists. Skipping creation."
else
  useradd -m -s /bin/bash "$USERNAME"
  echo "✅ User '$USERNAME' created."
fi

# === ADD TO WHEEL GROUP ===
echo "👥 Adding user '$USERNAME' to wheel group for sudo"
usermod -aG wheel "$USERNAME"

# === SETUP PASSWORDLESS SUDO ===
SUDO_FILE="/etc/sudoers.d/$USERNAME"
echo "🔐 Configuring passwordless sudo for '$USERNAME'"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDO_FILE"
chmod 440 "$SUDO_FILE"
echo "✅ Passwordless sudo configured"

# === GENERATE NEW SSH KEY PAIR ===
echo "🔑 Generating SSH key pair for '$USERNAME'"
SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p "$SSH_DIR"
ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/$KEY_NAME" -N "" -C "$USERNAME@$(hostname)"
cat "$SSH_DIR/${KEY_NAME}.pub" > "$SSH_DIR/authorized_keys"

# Set proper permissions
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/$KEY_NAME"
chmod 644 "$SSH_DIR/${KEY_NAME}.pub"

echo "✅ SSH key setup complete"

# === OPTIONAL: Show private key path ===
echo "📌 Private key for user '$USERNAME' saved at: $SSH_DIR/$KEY_NAME"
echo "📤 You can copy it with: scp $USERNAME@<host>:$SSH_DIR/$KEY_NAME ~/.ssh/"

echo "🎉 All done! Function account '$USERNAME' is ready for Kubernetes setup."
