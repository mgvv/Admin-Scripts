#!/bin/bash

# 1. Define Variables
TARGET_USER="mgveliz"
TARGET_GROUP="users"
HOME_DIR="/home/$TARGET_USER"
SSH_DIR="$HOME_DIR/.ssh"
AUTH_FILE="$SSH_DIR/authorized_keys"

# The OpenSSH Public Key provided
KEY_CONTENT="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLSV3CuCfX91OYNH+9+rzHrAiU/dr3qiHWHDqo9+ZebjJl0JoSVokzTWLZ3Loxkf2unnQTXW5+Pt4dnDoWe7zmrb5yWF1J/N0DLwCFfZFrz0jn7fLLZ+zd7ZoNA+/A+FsDpWR2Bvtf9lGKflQF2kyAJURZ/8gM3JYIiECcy02lwSdUtRXhvfyK56ac5yIhgxKVJsgF5BbFygf0r5L7Pn7W1OyUGaL9un1dONHC0++JKkHSCBBE3P+uQgUePPNtnkTtADyDIZeYCeBFRMSSta/qhp30/kIRoP5hkCwC8lFrauUEMLaLT9N0P7U4cc6qF/odkJecl9smiU9cyxwAPTpv mgveliz@oxya.com"

# 2. Check if the user exists
if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: User $TARGET_USER does not exist on this system."
    exit 1
fi

echo "Configuring SSH access for user: $TARGET_USER"

# 3. Create the .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    mkdir -vp "$SSH_DIR"
    echo "Created directory: $SSH_DIR"
else
    echo "Directory already exists: $SSH_DIR"
fi

# 4. Set Directory Permissions (Strictly 700)
# 700 = rwx------ (User can read/write/execute, others cannot enter)
chmod 700 "$SSH_DIR"

# 5. Append the key to authorized_keys
# We use grep -F (fixed string) to check if this specific key is already there
if grep -Fq "$KEY_CONTENT" "$AUTH_FILE" 2>/dev/null; then
    echo "Notice: This specific key is already present in authorized_keys."
else
    echo "$KEY_CONTENT" >> "$AUTH_FILE"
    echo "Success: Key appended to authorized_keys."
fi

# 6. Set File Permissions (Strictly 600)
# 600 = rw------- (User can read/write, others have no access)
chmod 600 "$AUTH_FILE"

# 7. Fix Ownership
# Because we run this with sudo, we must ensure mgveliz owns the files, not root.
chown -R "$TARGET_USER:$TARGET_GROUP" "$SSH_DIR"

echo "---------------------------------------------------"
echo "Setup complete. Permissions and ownership verified."
