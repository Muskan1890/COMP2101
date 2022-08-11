# Functions

function hardwareInformation {
  # Function to print hardware information including Name, Model, Manufacturer, TotalPhysicalMemory, Domain

  write-output "--- Hardware Description ---"
  
  Get-WmiObject win32_computersystem | Format-List Name, Model, Manufacturer, TotalPhysicalMemory, Domain
  

}
function OperatingSystemInformation {
  # Function to print Operating System information including OSArchitecture, Version, Caption

  write-output "--- Operating System Information ---"
  
  Get-WmiObject win32_operatingsystem | Select-Object OSArchitecture, Version, Caption | Format-List
  

}

function processorInformation {
  # Function to print Processor Information including Name, NumberOfCores, CurrectClockSpeed, MaxClockSpeed, L1CacheSize, L2CacheSize, L3CacheSize
  # And if the data is missing, it shows Data Not Found

  write-output "--- Processor Information ---"
  
  Get-WmiObject win32_processor |
  Select-Object Name, NumberOfCores, CurrectClockSpeed, MaxClockSpeed, 
  @{
    n = "L1CacheSize"; 
    e = { switch ($_.L1CacheSize) {
        $null { $value = "Data Not Found" }
        Default { $value = $_.L1CacheSize }
      };
      $value
    }
  },
  @{
    n = "L2CacheSize";
    e = { switch ($_.L2CacheSize) {
        $null { $value = "Data Not Found" }
        Default { $value = $_.L2CacheSize }
      };
      $value
    }
  },
  @{
    n = "L3CacheSize";
    e = { switch ($_.L3CacheSize) {
        $null { $value = "Data Not Found" }
        Default { $value = $_.L3CacheSize }
      };
      $value
    }
  } | Format-List

}

function RAMInformation {
  # Function to print RAM Information including Manufacturer, Description, Size, Bank, Slot and Total Ram Capacity

  write-output "--- RAM Information ---"
  
  $totalRamCapacity = 0
  
  Get-WmiObject win32_physicalmemory | 
  Foreach-Object {
    $ram = $_ ;
    New-Object -TypeName psObject -Property @{
      Manufacturer  = $ram.Manufacturer
      Description   = $ram.Description
      "Size(in GB)" = $ram.Capacity / 1gb
      BankLabel     = $ram.banklabel
      SlotLocator   = $ram.devicelocator
    }
    $totalRamCapacity += $ram.Capacity / 1gb
  } | Format-Table -AutoSize Manufacturer, Description, "Size(in GB)", BankLabel, SlotLocator
  
  write-output "Total RAM (GB) = $($totalRamCapacity)"

}

function diskInformation {
  # Function to print Physical Disk Information including Location, Drive, Manufacturer, Model, Size, FreeSpace

  write-output "--- Physical Disk Information ---"
  
  # Getting all disk drives in a single variable
  $diskdrives = Get-CIMInstance CIM_diskdrive | Where-Object DeviceID -ne $null

  foreach ($disk in $diskdrives) {
    $partitions = $disk | get-cimassociatedinstance -resultclassname CIM_diskpartition
    foreach ($partition in $partitions) {
      $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
      foreach ($logicaldisk in $logicaldisks) {
        new-object -typename psobject -property @{
          Location      = $partition.deviceid
          Drive         = $logicaldisk.deviceid
          Manufacturer  = $disk.Manufacturer
          Model         = $disk.Model
          FreeSpace     = (($logicaldisk.FreeSpace / 1gb -as [int]) -as [string]) + "GB"
          "Size(in GB)" = (($logicaldisk.Size / 1gb -as [int]) -as [string]) + "GB"
        } | Format-Table -AutoSize
      }
    }
  }

}

function networkIpInfo {
  # Function to get Network Information
  write-output "--- Network Adapter Information ---"

  Get-Ciminstance win32_networkadapterconfiguration | ? { $_.IPEnabled -eq $True } |
  Format-Table Index, Description, IPSubnet, DNSDomain, DNSServerSearchOrder, IPAddress -AutoSize;
 
}

function videoInformation {
  # Function to get Graphics Information
  write-output "--- Graphics Information ---"
  
  # Get Video Controller Information
  $videoController = Get-WmiObject win32_videocontroller
  
  # Create new object from the extracted object
  $information = New-Object -TypeName psObject -Property @{
    Name             = $videoController.Name
    Description      = $videoController.Description
    ScreenResolution = [string]($videoController.CurrentHorizontalResolution) + ' X ' + [string]($videoController.CurrentVerticalResolution)
  } | Format-List ScreenResolution, Name, Description 
  
  $information
}

# Execution Starts Here

hardwareInformation

OperatingSystemInformation

processorInformation

RAMInformation

diskInformation

networkIpInfo

videoInformation