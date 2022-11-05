. $PSScriptRoot\Test-Elevated.ps1

function Write-OSRelease {
  [Alias('Export-OSRelease')]
  param()

  begin {
    $OSRelease = @{}
    $OSRelease.FilePath = "$Env:ALLUSERSPROFILE\os-release"
    $OSRelease.Map = [ordered]@{}
    if($(Test-Path $OSRelease.FilePath) -and ((Get-Content $OSRelease.FilePath)).Trim().Length -gt 0){
      (Get-Content $OSRelease.FilePath).split([environment]::NewLine) | Where-Object { [string]$_ -gt 0 } | foreach {
        $Key = $_.Split('=')[0]
        $OSRelease.Map[$Key] = $_.Substring($Key.Length+1,$_.Length-$($Key.Length+1))
      }
    }else{
      if(Test-Path $Env:SystemDrive\etc){
        if(Test-Path $Env:SystemDrive\etc\os-release){
          Remove-Item $Env:SystemDrive\etc\os-release -Force
        }
      }
      New-Item -Path $OSRelease.FilePath -Value $null -Force | Out-Null
      if(Test-Path $Env:SystemDrive\etc){
        if(!(Test-Path $Env:SystemDrive\etc\os-release)){
          New-Item -Path $Env:SystemDrive\etc -Name os-release -ItemType SymbolicLink -Value $OSRelease.FilePath | Out-Null
        }
      }
    }
    $SystemInfo_Map = @{}
  }

  process {
    $(systeminfo | Out-String).split([Environment]::NewLine) | Where-Object { $null -ne $_ } | foreach {
      $SystemInfo_Map["$($_.split(':')[0] -replace ' ')"] = $_.split(':')[1]
    }
    @('HostName','OSName','Domain','SystemManufacturer','SystemModel','BIOSVersion') | ForEach-Object {
      switch($_){
        'OSName' { $Key = 'ProductName'; $Value = $SystemInfo_Map["$_"] -replace 'Microsoft ' }
        'Domain' { $Key = 'MachineDomain'; $Value = $SystemInfo_Map["$_"] }
        default { $Key = $_; $Value = $SystemInfo_Map["$_"] }
      }
      $OSRelease.Map[$Key] = [string]$('"' + $Value.Trim() + '"')
    }
  }

  end {
    if(Test-Elevated){
      New-Item -Path $OSRelease.FilePath -Value $null -Force | Out-Null
      $OSRelease.Map.GetEnumerator() | ForEach-Object {
        "$($_.Key)=$($_.Value)" | Out-File $OSRelease.FilePath -Append
      }
      $Output = $(Get-Item $OSRelease.FilePath)
    }else{
      Write-Error "No permissions to write to the /etc/os-release file. Key-values returned as output." -ErrorAction Continue
      $Output = $OSRelease.Map
    }
    return $Output
  }
}
