function Get-OSReleaseData {
  [Alias('osinfo')]
  param(
    [Parameter(Position=0)][string[]]$Key,
    [switch]$RegistryOnly,
    [switch]$FileOnly,
    [Alias('Path')][string]$FilePath="$Env:SystemDrive\etc\os-release"
  )

  $OSReleaseInfo = [ordered]@{}

  if(!$FileOnly.IsPresent){
    $Keys = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $Keys | Get-Member | Where-Object {
      $_.Name -notlike "PS*" -and $_.MemberType -eq "NoteProperty" -and $Keys."$_" -ne ""
    } | foreach {
      $OSReleaseInfo."$($_.Name)" = $Keys.$($_.Name)
    }
  }

  if(!$RegistryOnly.IsPresent){
    if((Test-Path $FilePath) -and ($null -ne $(Get-Content $FilePath))){
      $OSReleaseFile = Get-Content $FilePath
      $OSReleaseFile.split([System.Environment]::NewLine) | foreach {
        $Value_raw = $_ -replace "$($_.Split('=')[0])="
        $OSReleaseInfo."$($_.Split('=')[0])" = $Value_raw.Substring(1,$Value_raw.Length-2)
      }
    }elseif($FileOnly.IsPresent){
      Write-Warning "The os-release file does not exist." -ErrorAction Continue
    }
  }

  if($Key.Count -gt 0){
    $OSReleaseInfo.GetEnumerator() | Where-Object { $Key.ToLower().Contains($_.Name.ToLower()) }
  }else{
    return $OSReleaseInfo
  }
}
