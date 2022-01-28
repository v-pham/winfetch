function Export-OSReleaseInfo {
  param()

  begin {
    $OSRelease = @{}
    $OSRelease.File = "$Env:SystemRoot\system32\drivers\etc\os-release"
    $OSRelease.Map = [ordered]@{}
    if(!$(Test-Path $OSRelease.File) -or ($null -ne (Get-Content $OSRelease.File))){
      (Get-Content $OSRelease.File).split([environment]::NewLine) | Where-Object { [string]$_ -gt 0 } | foreach {
        $Key = $_.Split('=')[0]
        $OSRelease.Map[$Key] = $_.Substring($Key.Length+1,$_.Length-$($Key.Length+1))
      }
    }else{
        New-Item $OSRelease.File -Value $null -Force | Out-Null
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
    }
    $OSRelease.Map[$Key] = [string]$('"' + $Value.Trim() + '"')
  }

  end {
    New-Item -Path $OSRelease.File -Value $null -Force | Out-Null
    $OSRelease.Map.GetEnumerator() | foreach {
       "$($_.Key)=$($_.Value)" | Out-File $OSReleaseInfo.File -Append
    }
    return $(Get-Item $OSRelease.File)
  }
}

Export-ModuleMember -Function Export-OSReleaseInfo