function Test-Elevated {
<#
 .Synopsis
  Tests if current session is elevated with administrator privileges.

 .Description
  Tests if current security ID (SID) contains the Administrators group's well-known SID.

 .Parameter False
  Reverses the returned boolean, returning $True if current session is not elevated with administrator privileges.

 .Example
   # Show default
   Test-Elevated
#>
    [CmdletBinding()]
    [Alias('IsAdmin')]
    [OutputType([bool])]
    Param(
      [Parameter(Mandatory=$false)]
      [switch]$False
    )

    if($False.IsPresent){
      return !(([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544")
    }else{
      return (([Security.Principal.WindowsIdentity]::GetCurrent()).Groups -contains "S-1-5-32-544")
    }
}