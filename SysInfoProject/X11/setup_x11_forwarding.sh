#!/bin/bash

TARGET_USER="$1"

if [ -z "$TARGET_USER" ]; then
    echo "❌ Error: No target user specified."
    echo "Usage: $0 <target_user>"
    exit 1
fi

# Obtener el valor de DISPLAY, usar :0 como valor por defecto si no está definido
DISPLAY_VAL="${DISPLAY:-:0}"

if [ -z "$DISPLAY_VAL" ]; then
    echo "❌ Error: DISPLAY environment variable is not set."
    exit 2
fi

# Obtener el cookie de xauth para el DISPLAY actual
COOKIE=$(xauth list "$DISPLAY_VAL" 2>/dev/null | head -n 1)

if [ -z "$COOKIE" ]; then
    echo "❌ Error: No xauth cookie found for DISPLAY=$DISPLAY_VAL"
    exit 3
fi

# Guardar el cookie en archivo temporal
echo "$COOKIE" > /tmp/z_xauth
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to write xauth cookie to /tmp/z_xauth"
    exit 4
fi

# Verificar si sudo está disponible
if ! command -v sudo &> /dev/null; then
    echo "❌ Error: 'sudo' command not found. Cannot switch user to $TARGET_USER."
    rm -f /tmp/z_xauth
    exit 5
fi

# Verificar si el usuario actual tiene permisos para usar sudo con el usuario objetivo
if ! sudo -l -U "$USER" | grep -q "(ALL) NOPASSWD: ALL"; then
    echo "⚠️ Advertencia: Puede que se requiera contraseña para ejecutar comandos como $TARGET_USER."
fi

# Ejecutar como el usuario objetivo
sudo -u "$TARGET_USER" bash <<EOF
    if ! command -v xauth &> /dev/null; then
        echo "❌ Error: xauth not found for user $TARGET_USER"
        exit 6
    fi

    xauth add $COOKIE
    echo "✅ xauth list for $TARGET_USER:"
    xauth list
EOF

# Verificar si el comando sudo fue exitoso
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to execute xauth commands as user '$TARGET_USER'."
    rm -f /tmp/z_xauth
    exit 7
fi

# Limpiar archivo temporal
rm -f /tmp/z_xauth

