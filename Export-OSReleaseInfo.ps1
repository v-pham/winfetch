function Export-OSReleaseInfo {
  param()

  begin {
    $OSRelease = @{}
    $OSRelease.FilePath = "$Env:SystemRoot\system32\drivers\etc\os-release"
    $OSRelease.Map = [ordered]@{}
    if(!$(Test-Path $OSRelease.FilePath) -or ($null -ne (Get-Content $OSRelease.FilePath))){
      (Get-Content $OSRelease.FilePath).split([environment]::NewLine) | Where-Object { [string]$_ -gt 0 } | foreach {
        $Key = $_.Split('=')[0]
        $OSRelease.Map[$Key] = $_.Substring($Key.Length+1,$_.Length-$($Key.Length+1))
      }
    }else{
        New-Item -Path $OSRelease.FilePath -Value $null -Force | Out-Null
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
    New-Item -Path $OSRelease.FilePath -Value $null -Force | Out-Null
    $OSRelease.Map.GetEnumerator() | ForEach-Object {
       "$($_.Key)=$($_.Value)" | Out-File $OSRelease.FilePath -Append
    }
    return $(Get-Item $OSRelease.FilePath)
  }
}

Export-ModuleMember -Function Export-OSReleaseInfo