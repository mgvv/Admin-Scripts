# SAPinst Execution Wrapper

A robust Bash script designed to automate and simplify the execution of the SAP Software Provisioning Manager (`sapinst`). This script handles remote access configuration, Certificate Revocation List (CRL) validation, and environment pre-checks.

## 🚀 Features

* **Pre-execution Validation:** Ensures the `sapinst` binary and necessary CRL files are present before attempting execution, preventing partial starts or confusing installer errors.
* **Dynamic Hostname Detection:** Automatically detects the server's short hostname to configure the GUI hostname parameter accurately.
* **Remote GUI Configuration:** Pre-configures trusted remote access for a specific user.
* **Clear Logging & Error Handling:** Provides emoji-based console outputs for quick visual feedback and captures/returns standard exit codes.

## 📋 Prerequisites

Before running this script, ensure the following conditions are met:

1.  **Location:** The script must be placed and run from the same directory as the `sapinst` executable.
2.  **Permissions:** The script requires execution permissions (`chmod +x run_sapinst.sh`). You must also have the appropriate OS permissions (usually `root`) to run SAPinst.
3.  **CRL File:** Ensure the CRL file (`crlbag.p7s`) has been downloaded and placed in the directory specified by the `SAPINST_CRL_PATH` variable.

## ⚙️ Configuration

The script contains several hardcoded variables at the top of the file. You should modify these to match your specific environment and user requirements before running:

| Variable | Description | Default Value |
| :--- | :--- | :--- |
| `SAPINST_USER` | The OS user permitted to remotely access the SAP GUI. | `mgveliz` |
| `SAPINST_TRUSTED` | Designates if the remote user is trusted. | `true` |
| `SAPINST_CRL_PATH` | Absolute path to the local CRL file. | `/usr/sap/trans/MGW_Files/MGWADM/swpm/crlbag.p7s` |
| `SAPINST_INST` | Absolute path to the SWPM installation directory. | `/usr/sap/trans/MGW_Files/MGWADM/swpm/INST_DIR` |
| `SAPINST_CRL_SOURCE_URL` | The remote source URL for the CRL validation. | `https://tcs.mysap.com/crl/crlbag.p7s` |

## 💻 Usage

1. Navigate to the directory containing your unpacked SWPM/sapinst files:
   ```bash
   cd /path/to/swpm/
