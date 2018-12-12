function Write-SystemInformation {
[CmdletBinding()]
[Alias('screenfetch', 'neofetch', 'winfetch', 'sysfetch')]
param (
    [Parameter(Mandatory = $False)]
    [ValidateSet('Windows', 'PowerShell', 'None', IgnoreCase = $true)]
    [string]$AsciiLogo = 'Windows',
    [Parameter(Mandatory = $False)]
    [string[]]$PropertyList,
    [Parameter(Mandatory = $False)]
    [int]$PadLeft = 4,
    [Parameter(Mandatory = $False)]
    [int]$PadRight = 4
)

begin
{
switch ($AsciiLogo.ToLower()){
 "powershell" {
    [string[]]$Logo = @'
     .sdmmmmmmmmmmmmmmmmmmmmmmmmmdy-
    .NMMMMMMMNMMMMMMMMMMMMMMMMMMMMMy
    sMMMMMMN. `sMMMMMMMMMMMMMMMMMMM/
   `MMMMMMMMo`  .yMMMMMMMMMMMMMMMMN 
   oMMMMMMMMMN+   -dMMMMMMMMMMMMMMo 
  `NMMMMMMMMMMMm:   :mMMMMMMMMMMMN` 
  +MMMMMMMMMMMMMMh.   oMMMMMMMMMMs  
  mMMMMMMMMMMMMMh:  `/dMMMMMMMMMM.  
 /MMMMMMMMMMMd+`  :yNMMMMMMMMMMMh   
 dMMMMMMMMNs.  .omMMMMMMMMMMMMMM-   
:MMMMMMMy:  `+d/        mMMMMMMd    
hMMMMMMN:`/hMMMy+++++++oNMMMMMM/    
NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh     
-syhhhhhhhhhhhhhhhhhhhhhhhhys:      
'@.Split([System.Environment]::NewLine) | ? { $_.Length -gt 0 } }
 default { [string[]]$Logo = @"
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
          ''' '''::::::||||||||
                        '''''':
"@.Split([System.Environment]::NewLine) | ? { $_.Length -gt 0 } }
}
    
    $ColorScheme_Logo = 'Blue'
    $ColorScheme_Primary = 'White'
    $ColorScheme_Secondary = 'Gray'
    $ColorScheme_Keys = 'Cyan'
    $ColorScheme_Values = 'Gray'
    
    if (!$PropertyList)
    {
        [string[]]$PropertyList = @('OS', 'Host', 'Kernel', 'Uptime', 'Shell', 'Terminal', 'CPU', 'Memory')
    }
    
    $SystemProperty = [ordered]@{ }
    
    # Sort PropertyList to preferred ordered
    $AllProperties = @('OS', 'Host', 'Kernel', 'Uptime', 'Shell', 'Terminal', 'CPU', 'Memory')
    
}

process
{
    $ComputerInfo_OS = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $ComputerInfo_CPU = Get-ItemProperty -Path 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0'
    $ComputerInfo_Host = Get-ItemProperty -Path 'HKLM:\HARDWARE\DESCRIPTION\System\BIOS'
    $ComputerInfo_MachineDomain = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History' | Select-Object -ExpandProperty MachineDomain
    if ($env:PROCESSOR_ARCHITECTURE -match "64") { [string]$ComputerInfo_OS_arch = "x86_64" }
    else { [string]$ComputerInfo_OS_arch = "x86" }
    
    foreach ($Property in $AllProperties)
    {
        if ($PropertyList -contains "$Property")
        {
            switch ($Property.ToLower())
            {
                "os" { $SystemProperty["OS"] = [string]$($ComputerInfo_OS.ProductName + " (" + $ComputerInfo_OS.ReleaseId + ") " + $ComputerInfo_OS_arch) }
                "host" { $SystemProperty["Host"] = [string]($ComputerInfo_Host.SystemManufacturer + " " + $ComputerInfo_Host.SystemVersion) }
                "kernel" { $SystemProperty["Kernel"] = [string]$ComputerInfo_OS.CurrentMajorVersionNumber + "." + [string]$ComputerInfo_OS.CurrentMinorVersionNumber + "." + [string]$ComputerInfo_OS.CurrentBuildNumber + "." + [string]$ComputerInfo_OS.UBR }
                "uptime" {
                    $Timespan = New-TimeSpan -Start $([datetime]::ParseExact($(Get-WmiObject win32_operatingsystem | Select-Object -ExpandProperty LastBootupTime).Split('.')[0], 'yyyyMMddHHmmss', $null)) -End $(Get-Date) | Select-Object Days, Hours, Minutes
                    $Uptime = @()
                    if ($Timespan.Days -gt 0) { $Uptime = $Uptime + "$([string]$Timespan.Days + " days")" }
                    if ($Timespan.Hours -gt 0) { $Uptime = $Uptime + "$([string]$Timespan.Hours + " hours")" }
                    if ($Timespan.Minutes -gt 0) { $Uptime = $Uptime + "$([string]$Timespan.Minutes + " mins")" }
                    $SystemProperty["Uptime"] = $Uptime -join ", "
                }
                "shell" { $SystemProperty["Shell"] = "PowerShell $($PSVersionTable.PSVersion)" }
                "cpu" { $SystemProperty["CPU"] = $(((($ComputerInfo_CPU.ProcessorNameString -replace '\(R\)') -replace '\(TM\)') -replace " CPU") -replace "@", "($Env:NUMBER_OF_PROCESSORS) @") }
                "memory" {
                    $Memory = Get-WmiObject Win32_PhysicalMemory
                    $Memory_Total = "$(($Memory | Measure-Object -Sum -Property Capacity).Sum/1048576)MiB"
                    [string[]]$Memory_Units = @()
                    $Memory_Modules = @{ }
                    $Memory | foreach {
                        $Memory_Modules["$($_.Capacity/1048576)MiB"] = $Memory_Modules["$($_.Capacity/1048576)MiB"] + 1
                    }
                    $Memory_Modules.GetEnumerator() | foreach { $Memory_Units = $Memory_Units + "$([string]$_.Value + "x" + [string]$_.Name)" }
                    $SystemProperty["Memory"] = [string]$($Memory_Total + " ($($Memory_Units -join ','))")
                }
            }
        }
    }
}

end
{
    function Write-SystemProperty([string]$Name, [string]$Value, [int]$PadLength = 0)
    {
        if ($PadLength -gt 0)
        {
            [string]$Name = "$Name`: ".PadLeft($PadLength + "$Name`: ".Length)
        }
        else
        {
            [string]$Name = "$Name`: "
        }
        Write-Host -Object $Name -ForegroundColor $ColorScheme_Keys -NoNewline
        Write-Host -Object $Value -ForegroundColor $ColorScheme_Values
    }
    
    $LogoPadLength = $($Logo | Measure-Object -Property Length -Maximum).Maximum + $PadLeft + $PadRight
    
    Write-Host -Object $Env:USERNAME.PadLeft($LogoPadLength + $Env:USERNAME.Length) -ForegroundColor $ColorScheme_Primary -NoNewline
    Write-Host -Object '@' -ForegroundColor $ColorScheme_Secondary -NoNewline
    Write-Host -Object $Env:COMPUTERNAME -ForegroundColor $ColorScheme_Primary -NoNewline
    Write-Host -Object "$('.' + $ComputerInfo_MachineDomain)" -ForegroundColor $ColorScheme_Primary
    
    # Generate dash-bar of equal length of username@FQDN
    $i = 0
    [string]$bar = ""
    do
    {
        $bar = $bar + "-"
        $i++
    }
    until ($i -eq "$Env:USERNAME`@$Env:COMPUTERNAME.$ComputerInfo_MachineDomain".Length)
    
    #TODO: Got lazy here, I just wanted it to run.
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
    @('Black', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'Gray') | foreach { Write-Host "   " -BackgroundColor $_ -NoNewline };
    Write-Host ""
    Do
    {
        Write-Host -Object "".PadLeft($PadLeft) -NoNewline
        Write-Host -Object $Logo[$i] -ForegroundColor $ColorScheme_Logo
        $i++
    }
    while ($i -lt $Logo.Count)
}
}