# sysfetch
A pseudo-neofetch PowerShell implementation.

This was heavily inspired by the following projects (and honestly, probably better implementations):

* https://github.com/dylanaraps/neofetch
* https://github.com/JulianChow94/Windows-screenFetch
* https://github.com/KittyKatt/screenFetch

I originally meant to fork Windows-screenfetch and modify the logo but I got carried away and ended up just coding it from start to finish.

At some point I'll probably add an option to use a "PowerShell" ASCII logo (if I can find one I like or get bored and find an easy way to do it myself). But the baseline is here and can be expanded upon later.

# Usage

I have this is a local code dump and source the .ps1 file in my default profile but probably will form a proper module later on if it's expanded upon in the future.

```powershell
# The following was appended to C:\windows\SysWOW64\WindowsPowerShell\v1.0\profile.ps1

source \path\to\Write-SystemInformation.ps1
```

I add it things to the 32-bit profile which in turn is sourced by my 64-bit profile because I like to keep both environments consistent and don't like to maintain two different `profile.ps1`.
