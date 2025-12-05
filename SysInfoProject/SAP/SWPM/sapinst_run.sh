
#!/bin/bash
# Script to run sapinst with remote access and CRL path configuration
# Includes error handling and short hostname detection

# Variables
SAPINST_USER="mgveliz"
SAPINST_TRUSTED="true"
SAPINST_CRL_PATH="/usr/sap/trans/MGW_Files/MGWADM/swpm/crlbag.p7s"
SAPINST_INST="/usr/sap/trans/MGW_Files/MGWADM/swpm/INST_DIR"
SAPINST_CRL_SOURCE_URL="https://tcs.mysap.com/crl/crlbag.p7s"

# Get short hostname (without domain)
HOSTNAME=$(hostname -s)

echo "ℹ️ Running on server: $HOSTNAME"

# Check if sapinst binary exists
if [[ ! -x "./sapinst" ]]; then
    echo "❌ Error: sapinst executable not found in current directory."
    exit 1
fi

# Check if CRL file exists
if [[ ! -f "$SAPINST_CRL_PATH" ]]; then
    echo "❌ Error: CRL file not found at $SAPINST_CRL_PATH"
    exit 2
fi

# Run sapinst
echo "✅ Starting sapinst on $HOSTNAME..."
./sapinst SAPINST_REMOTE_ACCESS_USER="$SAPINST_USER" \
          SAPINST_REMOTE_ACCESS_USER_IS_TRUSTED="$SAPINST_TRUSTED" \
          SAPINST_CRL_SOURCE_URL="$SAPINST_CRL_SOURCE_URL" \
          SAPINST_INST="$SAPINST_INST" \
          SAPINST_GUI_HOSTNAME="$HOSTNAME"

# Capture exit code
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
    echo "❌ sapinst failed on $HOSTNAME with exit code $EXIT_CODE"
    exit $EXIT_CODE
else
    echo "✅ sapinst completed successfully on $HOSTNAME."
fi
