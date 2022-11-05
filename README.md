# winfetch

Written specifically for Windows systems, mimicking neofetch's output which displays a quick summary of the currently running Windows system and hardware details.

# General usage and publishing locally

Simply import and run it after cloning locally.

*NOTE:* is a defined alias of the module but the proper PowerShell function is named `Write-SystemInformation` to follow the proper guideline on accepted verbs:

```
PS > Import-Module $PATH_TO_REPO\winfetch.psd1
PS > neofetch
                                        username@localhost.localdomain
                      ......::::::|     ---------------------------------
    .....:::::::| |||||||||||||||||     OS: Windows 10 Pro (22H2) x86_64
    ||||||||||||| |||||||||||||||||     Host: Lenovo ThinkPad P50 (20EQ000CTO)
    ||||||||||||| |||||||||||||||||     Kernel: 10.0.19045.2130
    ||||||||||||| |||||||||||||||||     Uptime: 1 day, 10 hours, 5 mins
    ||||||||||||| |||||||||||||||||     Shell: PowerShell 7.2.7
    ............. .................     Terminal: Windows Terminal
    ||||||||||||| |||||||||||||||||     CPU: Intel Core i7-6820HQ (8) @ 2.70GHz
    ||||||||||||| |||||||||||||||||     GPU: NVIDIA Quadro M1000M
    ||||||||||||| |||||||||||||||||     Memory: 9.48/64GB (4x 16GB)
    :::::|||||||| |||||||||||||||||
                ' ''''::::::|||||||
                                  '
```

The following command to create a nuget package and publish to a local or private PS repository:

```
PS > Publish-Module -Name winfetch -Repository $SOME_PSREPO
```
