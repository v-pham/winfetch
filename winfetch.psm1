. $PSScriptRoot\Get-OSReleaseInfo.ps1
. $PSScriptRoot\Export-OSReleaseInfo.ps1

function Write-SystemProperty([string]$Name, [string]$Value, [int]$PadLength = 0) {
  if ($PadLength -gt 0){
    [string]$Name = "$Name`: ".PadLeft($PadLength + "$Name`: ".Length)
  }
  else{
    [string]$Name = "$Name`: "
  }
  Write-Host -Object $Name -ForegroundColor $ColorScheme_Keys -NoNewline
  Write-Host -Object $Value -ForegroundColor $ColorScheme_Values
}

function Write-SystemInformation {
<#
 .Synopsis
  Displays information about the operating system, software and hardware.

 .Description
  Displays information about the operating system, software and hardware, mimicking "neofetch" on Linux systems.

 .Parameter AsciiLogo
  Specify the accompanying ASCII logo (Windows or PowerShell).

 .Parameter Shell
  Manually set the shell to display (PowerShell or Command).

 .Parameter MemoryUnit
  Select the unit when calculating system memory sizes (GB, MB, or KB).

 .Parameter PropertyList
  Specify the properties to include in the displayed output.

 .Parameter IncludeGPU
  Include GPU property. By default, GPU is only included when session ID is not equal to 0.

 .Parameter PadLeft
  Specify the number of spaces to pad left of the ASCII logo.

 .Parameter PadRight
  Specify the number of spaces to pad right of the ASCII logo.

 .Example
   # Show default display
   neofetch

 .Example
   # Show display, and manually set "Command" shell (helpful for use when invoked from Command Prompt)
   neofetch -shell command
#>

  [CmdletBinding()]
  [Alias('screenfetch', 'neofetch', 'winfetch', 'sysfetch')]
  param (
    [Parameter(Mandatory = $False)]
    [ValidateSet('Windows', 'PowerShell', 'None', IgnoreCase = $true)]
    [string]$AsciiLogo = 'Windows',
    [ValidateSet('Command', 'PowerShell', IgnoreCase = $true)]
    [string]$Shell='PowerShell',
    [Parameter(Mandatory=$False)]
    [ValidateSet('KB','MB','GB','KiB','MiB','GiB', IgnoreCase = $true)]
    [string]$MemoryUnit = 'GB',
    [Parameter(Mandatory = $False)]
    [string[]]$PropertyList,
    [Parameter(Mandatory = $False)]
    [Alias('GPU')]
    [switch]$IncludeGPU,
    [Parameter(Mandatory = $False)]
    [int]$PadLeft = 4,
    [Parameter(Mandatory = $False)]
    [int]$PadRight = 4
  )

  begin {
[string[]]$Logo_Windows = @"
                  ......::::::|
.....:::::::| |||||||||||||||||
||||||||||||| |||||||||||||||||
||||||||||||| |||||||||||||||||
||||||||||||| |||||||||||||||||
||||||||||||| |||||||||||||||||
............. .................
||||||||||||| |||||||||||||||||
||||||||||||| |||||||||||||||||
||||||||||||| |||||||||||||||||
:::::|||||||| |||||||||||||||||
            ' ''''::::::|||||||
                              '
"@.Split([System.Environment]::NewLine) | Where-Object { $_.Length -gt 0 } | foreach { $_.PadRight(32) }

[string[]]$Logo_PowerShell = @"
         __________________
       /OA(  V||||||||||||||y
      /////\  \\\\\\\\\\\\\V/
     ///////\  \\\\\\\\\\\V/
    ///////'  .A\\\\\\\\\V/
   /////'  ='AV///////////
  ///'  =AV(''''''''')AV/
  'O|v////////////////O
"@.Split([System.Environment]::NewLine) | Where-Object { $_.Length -gt 0 } | foreach { $_.PadRight(32) }
    $Logo_PowerShell = ,"".PadRight(32) + ,"".PadRight(32) + $Logo_PowerShell
    $Logo_PowerShell = $Logo_PowerShell + "".PadRight(32) + "".PadRight(32) + "".PadRight(32)

    $ColorScheme_Logo = 'Blue'
    $ColorScheme_Primary = 'White'
    $ColorScheme_Secondary = 'Gray'
    $ColorScheme_Keys = 'Cyan'
    $ColorScheme_Values = 'Gray'

    if (!$PropertyList)
    {
      [string[]]$PropertyList = @('OS', 'Host', 'Kernel', 'Uptime', 'Shell', 'Terminal', 'CPU', 'Memory')
    }
    if(((Get-Process -PID $pid).SessionID -ne 0) -or $IncludeGPU.IsPresent){
      $PropertyList += 'GPU'
    }
    $SystemProperty = [ordered]@{ }

    # Sort PropertyList to preferred order
    $AllProperties = @('OS', 'Host', 'Kernel', 'Uptime', 'Shell', 'Terminal', 'CPU', 'GPU', 'Memory')
    $MemoryDisplayUnit = @{
      KiB = 1024
      MiB = 1048576
      GiB = 1073741824
    }
    $MemoryDisplayUnit.GetEnumerator().Name | foreach { $MemoryDisplayUnit.$($_ -replace 'i') = $MemoryDisplayUnit."$_" }
    $MemoryUnit = $MemoryDisplayUnit.Keys | Where-Object { $_ -like "$MemoryUnit" }
  }

  process
  {
    $ComputerInfo_OS = Get-OSReleaseInfo
    if($ComputerInfo_OS['ProductName'] -like '*Nano*'){
      $IsNano = $true
    }else{
      $IsNano = $false
    }
    [string[]]$CPUQueryOutput = @()
    if($IsNano){
      Get-CimInstance -ComputerName localhost -Class CIM_Processor -ErrorAction Stop | Select-Object Name, NumberOfLogicalProcessors | foreach { $CPUQueryOutput += "$($_.Name + "  " + $_.NumberOfLogicalProcessors)" }
    }else{
      (wmic cpu get 'Name,NumberOfLogicalProcessors' | Out-String).split([System.Environment]::NewLine) | Where-Object { $_.Trim().Length -gt 0 -and !$_.StartsWith('Name') } | foreach { $CPUQueryOutput+= $_.Trim() }
    }
    $ComputerInfo_CPU = $CPUQueryOutput | foreach {
      $Threads = ($_ -split "\s{2,}")[-1].Trim()
      $($_ -replace '\(R\)' -replace '\(TM\)' -replace " CPU" -split "\s{2,}")[0] -replace ' @'," ($Threads) @" -replace '\s+', ' '
    }
    $ComputerInfo_Host = Get-ItemProperty -Path 'HKLM:\HARDWARE\DESCRIPTION\System\BIOS'
    try {
      [string]$ComputerInfo_MachineDomain = "." + $(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History' -ErrorAction Stop | Select-Object -ExpandProperty MachineDomain -ErrorAction Stop)
    }catch {
      [string]$ComputerInfo_MachineDomain = $ComputerInfo_OS["MachineDomain"]
    }
    if ($env:PROCESSOR_ARCHITECTURE -match "64") { [string]$ComputerInfo_OS_arch = "x86_64" }
    else { [string]$ComputerInfo_OS_arch = "x86" }

    if($ComputerInfo_OS.DisplayVersion.Length -eq ""){ $ComputerInfo_OS_DisplayId = $ComputerInfo_OS.ReleaseId }else{ $ComputerInfo_OS_DisplayId = $ComputerInfo_OS.DisplayVersion }

    foreach ($Property in $AllProperties){
      if ($PropertyList -contains "$Property"){
        switch ($Property.ToLower()){
          "os" { $SystemProperty["OS"] = [string]$($ComputerInfo_OS.ProductName + " (" + $ComputerInfo_OS_DisplayId + ") " + $ComputerInfo_OS_arch) }
          "host" {
            if($null -ne $ComputerInfo_OS.HostModel){ [string]$HostModel = " (" + $ComputerInfo_OS.HostModel + ")" }else{ [string]$HostModel = '' }
            $SystemProperty["Host"] = [string]($ComputerInfo_Host.SystemManufacturer + " " + $ComputerInfo_Host.SystemVersion + $HostModel)
          }
          "kernel" { $SystemProperty["Kernel"] = [string]$ComputerInfo_OS.CurrentMajorVersionNumber + "." + [string]$ComputerInfo_OS.CurrentMinorVersionNumber + "." + [string]$ComputerInfo_OS.CurrentBuildNumber + "." + [string]$ComputerInfo_OS.UBR }
          "uptime" {
            if($PSVersionTable.PSVersion.Major -eq 5){
              $Timespan = New-TimeSpan -Start (Get-CimInstance -ClassName win32_operatingsystem | Select-Object -ExpandProperty LastBootUpTime) -End (Get-Date) | Select-Object Days, Hours, Minutes
            }else{
              $Timespan = uptime | Select-Object Days, Hours, Minutes
            }
            $Uptime = @()
            if ($Timespan.Days -gt 0) {
              if($Timespan.Days -gt 1){ $Unit_suffix = "s" }else{ $Unit_suffix = "" }
              $Uptime = $Uptime + "$([string]$Timespan.Days + " day" + $Unit_suffix)"
            }
            if ($Timespan.Hours -gt 0) {
              if($Timespan.Hours -gt 1){ $Unit_suffix = "s" }else{ $Unit_suffix = "" }
              $Uptime = $Uptime + "$([string]$Timespan.Hours + " hour" + $Unit_suffix)"
            }
            if ($Timespan.Minutes -gt 0) {
              if($Timespan.Minutes -gt 1){ $Unit_suffix = "s" }else{ $Unit_suffix = "" }
              $Uptime = $Uptime + "$([string]$Timespan.Minutes + " min" + $Unit_suffix)"
            }
            $SystemProperty["Uptime"] = $Uptime -join ", "
          }
          "shell" {
            switch($Shell.ToLower()){
              "command" { $SystemProperty["Shell"] = "Command $($SystemProperty["Kernel"])" }
              default   { $SystemProperty["Shell"] = "PowerShell $($PSVersionTable.PSVersion)" }
            }
          }
          "terminal" {
            if($IsWindowsTerminal -or $Env:WT_SESSION.Length -gt 0) {
              $wt_exe = Get-Item -Path (Get-Command wt).Source
              if($wt_exe.Target.Length -gt 0) {
                $SystemProperty["Terminal"] = "Windows Terminal $($wt_exe.Target.Split('\')[-2].Split('_')[-4])"
              } else {
                $SystemProperty["Terminal"] = "Windows Terminal $(($wt_exe | Split-Path -Parent).Split('\')[-1].Split('_')[1])"
              }
            }elseif($IsCodeTerminal) {
              $SystemProperty["Terminal"] = "VS Code $((code -v)[0]) Integrated Terminal"
            }else{
              $SystemProperty["Terminal"] = "Windows Console $($SystemProperty["Kernel"])"
            }
          }
          "cpu" {
            if($ComputerInfo_CPU.Count -eq 1){ $SystemProperty["CPU"] = $ComputerInfo_CPU }
            else{
              $CPUInfo = @{}
              $ComputerInfo_CPU | foreach {
                if($null -eq $CPUInfo["$_"]){ $CPUInfo["$_"] = 1 }
                else{ $CPUInfo["$_"] = $CPUInfo["$_"]+1 }
              }
              $SystemProperty["CPU"] = "$($CPUInfo.GetEnumerator() | foreach { "$([string]$_.Value + "x " + $_.Name)" })" -join ', '
            }
          }
          "gpu" { $SystemProperty["GPU"] = [string]$(((Get-PnpDevice -Class Display -Status OK | Where-Object { $_.FriendlyName -notlike 'Microsoft*Remote*' }).FriendlyName -replace '\(R\)')  -join ', ') }
          "memory" {
            if($IsNano){
              $Memory = (Get-CimInstance -Class Win32_PerfRawData_Counters_HyperVDynamicMemoryIntegrationService | Select-Object -ExpandProperty MaximumMemoryMBytes)*1048576
            }else {
              $Memory = wmic MemoryChip get Capacity | Where-Object { $_.Length -gt 0 -and $_.Trim() -notlike 'Capacity' }
            }
            $Memory = $Memory | foreach { New-Object pscustomobject -Property @{ Capacity = $_ } }
            $Memory_Total = ($Memory | Measure-Object -Sum -Property Capacity).Sum/$MemoryDisplayUnit.$MemoryUnit
            if($IsNano){
              $SystemProperty["Memory"] = "$Memory_Total$($MemoryUnit)"
            }else {
              $Memory_Free = $((wmic os get FreePhysicalMemory /value | Where-Object { $_.Length -gt 0 }).Split('=')[-1])/$($MemoryDisplayUnit.$MemoryUnit/1024)
              [string[]]$Memory_Units = @()
              $Memory_Modules = @{ }
              $Memory | foreach {
                  $Memory_Modules["$($_.Capacity/$MemoryDisplayUnit.$MemoryUnit)$MemoryUnit"] = $Memory_Modules["$($_.Capacity/$MemoryDisplayUnit.$MemoryUnit)$MemoryUnit"] + 1
              }
              $Memory_Modules.GetEnumerator() | foreach { $Memory_Units = $Memory_Units + "$([string]$_.Value + "x " + [string]$_.Name)" }
              $SystemProperty["Memory"] = [string]$([math]::Round($($Memory_Total-$Memory_Free),2).ToString() + "/" + $Memory_Total.ToString() + "$MemoryUnit ($($Memory_Units -join ', '))")
            }
          }
        }
      }
    }
  }

  end {
    switch($AsciiLogo.ToLower()){
      "powershell" { $Logo = $Logo_PowerShell }
      default { $Logo = $Logo_Windows }
    }
    $LogoPadLength = $($Logo | Measure-Object -Property Length -Maximum).Maximum + $PadLeft + $PadRight

    Write-Host -Object $Env:USERNAME.PadLeft($LogoPadLength + $Env:USERNAME.Length) -ForegroundColor $ColorScheme_Primary -NoNewline
    Write-Host -Object '@' -ForegroundColor $ColorScheme_Secondary -NoNewline
    Write-Host -Object $Env:COMPUTERNAME -ForegroundColor $ColorScheme_Primary -NoNewline
    Write-Host -Object "$ComputerInfo_MachineDomain" -ForegroundColor $ColorScheme_Primary

    # Generate dash-bar of equal length of username@FQDN
    [string]$bar = "".PadLeft("$Env:USERNAME`@$Env:COMPUTERNAME.$ComputerInfo_MachineDomain".Length-1,'-')

    $i = 0
    Write-Host -Object "".PadLeft($PadLeft) -NoNewline
    Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo -NoNewline; $i++
    Write-Host -Object "".PadLeft($PadRight) -NoNewline
    Write-Host -Object $bar -ForegroundColor $ColorScheme_Secondary
    $SystemProperty.GetEnumerator() | foreach {
      Write-Host -Object "".PadLeft($PadLeft) -NoNewline
      Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo -NoNewline
      Write-SystemProperty -Name $_.Name -Value $_.Value -PadLength $PadRight
      $i++
    }
    Write-Host -Object "".PadLeft($PadLeft) -NoNewline
    Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo; $i++
    Write-Host -Object "".PadLeft($PadLeft) -NoNewline
    Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo -NoNewline; $i++
    Write-Host -Object "".PadLeft($PadRight) -NoNewline
    @('Black', 'DarkRed', 'DarkGreen', 'DarkYellow', 'DarkBlue', 'DarkMagenta', 'DarkCyan', 'Gray') | foreach { Write-Host "   " -BackgroundColor $_ -NoNewline };
    Write-Host ""
    Write-Host -Object "".PadLeft($PadLeft) -NoNewline
    Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo -NoNewline; $i++
    Write-Host -Object "".PadLeft($PadRight) -NoNewline
    @('DarkGray', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'White') | foreach { Write-Host "   " -BackgroundColor $_ -NoNewline };
    Write-Host ""
    Do {
      Write-Host -Object "".PadLeft($PadLeft) -NoNewline
      Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo
      $i++
    } while ($i -lt $Logo.Count)
  }
}

Export-ModuleMember -Function @('Write-SystemInformation','Export-OSReleaseInfo','Get-OSReleaseInfo','Export-OSReleaseInfo') -Alias @('neofetch','osinfo')
