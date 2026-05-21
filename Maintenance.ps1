# ==============================================================================
# ENTERPRISE AUTOMATION & SECURITY COMPLIANCE ENGINE
# MAIN DEPLOYMENT PIPELINE - COMPATIBLE WITH WINDOWS 10/11
# AUTHOR: DAVID MORALES / SYSTEMS ENGINEER
# ==============================================================================

# Ensure structural logging directory exists
$LogPath = "C:\ProgramData\Automation"
if (!(Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }
$LogFile = "$LogPath\FleetMetrics.csv"

Write-Output "[*] Initializing automated environment optimization..."

# [1. STORAGE RECLAMATION & SSD MANAGEMENT]
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Optimize-Volume -DriveLetter C -ReTrim

# [2. KERNEL & CORE SYSTEM REPAIR]
sfc /scannow
DISM /Online /Cleanup-Image /StartComponentCleanup

# [3. PROTOCOL STACK RESET]
ipconfig /flushdns
netsh winsock reset > $null

# [4. SECURITY INTEGRITY AUDITING]
$BitLocker = (Get-BitLockerVolume -MountPoint "C:").ProtectionStatus
$Defender = (Get-MpComputerStatus).RealTimeProtectionEnabled

# Language-agnostic detection for Local Administrators group
$GroupName = if (Get-LocalGroup -Name "Administrators" -ErrorAction SilentlyContinue) { "Administrators" } else { "Administradores" }
$AdminCount = (Get-LocalGroupMember -Group $GroupName).Count

# [5. TELEMETRY DATA INGESTION FOR POWER BI]
[PSCustomObject]@{
    Timestamp         = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    DeviceName        = $env:COMPUTERNAME
    BitLockerActive   = $BitLocker
    DefenderActive    = $Defender
    AdminAccountCount = $AdminCount
} | Export-Csv -Path $LogFile -Append -NoTypeInformation

Write-Output "[+] Optimization sequence concluded. Telemetry logged to FleetMetrics.csv"
