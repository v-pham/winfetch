# winfetch

Written specifically for Windows systems, mimicking neofetch's output which displays a quick summary of the currently running Windows system and hardware details.

# Publishing and general usage

Run the following command to create a nuget package and publish to a local PS repository:

```
Publish-Module -Name winfetch -Repository $LocalPSRepo
```

But you can simply run it after cloning:

```
Import-Module $PATH_TO_REPO\winfetch.psd1
neofetch # this is a defined alias of the module but the proper PowerShell function is named Write-SystemInformation
```

