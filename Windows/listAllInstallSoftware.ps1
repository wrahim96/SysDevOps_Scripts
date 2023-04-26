Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
    | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate `
    | Sort-Object DisplayName