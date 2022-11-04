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
