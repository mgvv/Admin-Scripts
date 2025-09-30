#!/bin/bash

TARGET_USER=\"$1\"

if [ -z \"$TARGET_USER\" ]; then
    echo \"Error: No target user specified.\"
    echo \"Usage: $0 <target_user>\"
    exit 1
fi

DISPLAY_VAL=$(env | grep DISPLAY | cut -d= -f2)
if [ -z \"$DISPLAY_VAL\" ]; then
    echo \"Error: DISPLAY environment variable is not set.\"
    exit 2
fi

COOKIE=$(xauth list | grep \"unix$(echo $DISPLAY_VAL | cut -c10-12)\")
if [ -z \"$COOKIE\" ]; then
    echo \"Error: No xauth cookie found for DISPLAY=$DISPLAY_VAL\"
    exit 3
fi

echo \"$COOKIE\" > /tmp/z_xauth
if [ $? -ne 0 ]; then
    echo \"Error: Failed to write xauth cookie to /tmp/z_xauth\"
    exit 4
fi

sudo -u \"$TARGET_USER\" bash <<EOF
    if ! command -v xauth &> /dev/null; then
        echo \"Error: xauth not found for user $TARGET_USER\"
        exit 5
    fi

    xauth add $COOKIE
    echo \"xauth list for $TARGET_USER:\"
    xauth list
EOF

rm -f /tmp/z_xauth

echo \"✅ X11 forwarding setup complete for user '$TARGET_USER'.\"
