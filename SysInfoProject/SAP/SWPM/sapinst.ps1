# Define variables
$SapinstPath      = "K:\The_SWPM\SWPM10SP45_2\sapinst.exe"
$RemoteAccessUser = "SPROPANE\sapbasis1"
$IsTrusted        = "true"
$CrlPath          = "K:\The_SWPM\crlbag_DEC_02_25.p7s"
$BrowserPath      = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$CrlSourceUrl     = "https://tcs.mysap.com/crl/crlbag.p7s"

# Execute sapinst with parameters
& $SapinstPath `
    SAPINST_REMOTE_ACCESS_USER=$RemoteAccessUser `
    SAPINST_REMOTE_ACCESS_USER_IS_TRUSTED=$IsTrusted `
    SAPINST_CRL_PATH=$CrlPath `
    SAPINST_BROWSER="$BrowserPath" `
    SAPINST_CRL_SOURCE_URL="$CrlSourceUrl"
