Get-ChildItem $PSScriptRoot\functions\private -Filter '*ps1' | foreach {
. $_.FullName
}

$Export = @{
  Function = [System.Collections.ArrayList]::New()
  Alias = [System.Collections.ArrayList]::New()
}
Get-ChildItem $PSScriptRoot\functions\public -Filter '*ps1' | foreach {
. $_.FullName
  $Export.Function.Add($_.BaseName) | Out-Null
  ((Get-Command $_.BaseName | Select-Object -ExpandProperty Definition).Split([Environment]::NewLine) | Where-Object {
    $_.Trim() -match '\[Alias\(.*'
  } | Select-Object -First 1).Split('(',2)[-1].Split(')',2)[0].Replace("'",'').Split(',').Trim() | foreach { $Export.Alias.Add($_) | Out-Null }
}

Export-ModuleMember -Function $Export.Function -Alias $Export.Alias