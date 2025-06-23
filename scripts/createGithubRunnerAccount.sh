#!/bin/bash

# Default variables
RUNNER_USER="github-runner"
SHELL_PATH="/bin/bash"
HOME_DIR="/home/$RUNNER_USER"
ADD_TO_DOCKER_GROUP=true
ADD_TO_SUDO_GROUP=false

# Create user if it doesn't exist
if id "$RUNNER_USER" &>/dev/null; then
  echo "User $RUNNER_USER already exists."
else
  echo "Creating user $RUNNER_USER..."
  useradd -m -d "$HOME_DIR" -s "$SHELL_PATH" "$RUNNER_USER"
  passwd -l "$RUNNER_USER"  # Lock password to prevent login
  echo "User $RUNNER_USER created."
fi

# Add to docker group
if [ "$ADD_TO_DOCKER_GROUP" = true ]; then
  if getent group docker >/dev/null; then
    usermod -aG docker "$RUNNER_USER"
    echo "Added $RUNNER_USER to docker group."
  else
    echo "Warning: docker group not found. Skipping."
  fi
fi

# Add to sudo group
if [ "$ADD_TO_SUDO_GROUP" = true ]; then
  usermod -aG sudo "$RUNNER_USER" 2>/dev/null || usermod -aG wheel "$RUNNER_USER"
  echo "Added $RUNNER_USER to sudo group."
fi

# Set ownership of home dir
chown -R "$RUNNER_USER:$RUNNER_USER" "$HOME_DIR"

# Summary
echo "✅ GitHub Runner user setup complete:"
echo "   - User: $RUNNER_USER"
echo "   - Home: $HOME_DIR"
echo "   - Shell: $SHELL_PATH"