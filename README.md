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

I have this is a local code dump and source the .ps1 file in my default profile but probably will form a proper module later on if it's expanded upon in the future.

```powershell
# The following was appended to C:\windows\SysWOW64\WindowsPowerShell\v1.0\profile.ps1

source \path\to\Write-SystemInformation.ps1
```

I add it things to the 32-bit profile which in turn is sourced by my 64-bit profile because I like to keep both environments consistent and don't like to maintain two different `profile.ps1`.
