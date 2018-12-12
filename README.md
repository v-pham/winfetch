# Write-SystemInformation
## (or `sysfetch`, as I've informally chosen to alias it)
A pseudo-neofetch PowerShell implementation.

This was heavily inspired by the following projects (and honestly, all of them are probably better implementations):

* https://github.com/dylanaraps/neofetch
* https://github.com/JulianChow94/Windows-screenFetch
* https://github.com/KittyKatt/screenFetch

I just wanted something like neofetch without any dependency on anything other than PowerShell (which led me to windows-screenfetch) but the logo looked off to me. Being bored and needlessly picky, I originally meant to fork Windows-screenfetch and just modify the logo but I got carried away and ended up just coding it all the way.

At some point I'll probably add an option to use a "PowerShell" ASCII logo and see if it can't be used on PowerShell Core on Linux.

# Usage

I have this in a local code dump and source the .ps1 file in my default profile but probably will form a proper module later on if it's expanded upon in the future but the script itself simply defines a function, `Write-SystemInformation`. Dot-source the script (i.e. run the script but put a `.` in front which will allow the function definition to persist in the current session) then call the function.

I make the function always available by sourcing the script within my system profile:

```powershell
# The following can be appended to one of the multiple PowerShell profiles (I use `C:\windows\SysWOW64\WindowsPowerShell\v1.0\profile.ps1` which in turn is dot-sourced within my 64-bit PowerShell profile) so it is automatically sourced:

. \path\to\Write-SystemInformation.ps1
```

Once it is dot-sourced, call the function `Write-SystemInformation' (or use one of its aliases):

## Example 1
```powershell
# Call the function using its defined name and display the default ASCII Windows logo

Write-SystemInformation
```

## Example 2
```powershell
# Call the function via one of its aliases and display the ASCII PowerShell logo

sysfetch -AsciiLogo PowerShell
```

