# Powershell Lab 3 - Muskan Sharma

# function to get network information
function networkIpInfo {
  Get-Ciminstance win32_networkadapterconfiguration | ? { $_.IPEnabled -eq $True } |
  FT Index, Description, IPSubnet, DNSDomain, DNSServerSearchOrder, IPAddress -AutoSize;
}
# Calling the function
networkIpInfo