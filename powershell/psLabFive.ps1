# Parameters
param (
  [switch]$System,
  [switch]$Disks,
  [switch]$Network
)

# No Parameters
if ( !($System) -and !($Disks) -and !($Network)) {
  hardwareInformation
  processorInformation
  OperatingSystemInformation
  RAMInformation
  videoInformation
  diskInformation
  networkIpInfo
}

# -System Parameter
if ($System) {
  hardwareInformation
  processorInformation
  OperatingSystemInformation
  RAMInformation
  videoInformation
}

# -Disk Parameter
if ($Disks) {
  diskInformation
}

# -Network Parameter
if ($Network) {
  networkIpInfo
}