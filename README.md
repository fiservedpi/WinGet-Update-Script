<img width="1024" height="1024" alt="generated-image" src="https://github.com/user-attachments/assets/345a1393-6485-4a3d-adf4-ed9112b9ca3b" />
# Installer Vault Release

Installer Vault is a PowerShell-based Windows utility for managing app downloads with WinGet.

## What it does
- Scans installed apps.
- Downloads installers into a local folder.
- Keeps a local copy for later use.

## Requirements
- Windows 10 or 11.
- PowerShell 5.1 or PowerShell 7.
- WinGet installed.
- PS2EXE module for EXE export.

## Install the build module
```powershell
Install-Module ps2exe -Scope CurrentUser
Import-Module ps2exe
```

## Export to EXE
```powershell
Invoke-ps2exe -InputFile .\UpdateVaultv2.ps1 -OutputFile .\UpdateVault.exe

```

## Optional build variations
```powershell
Invoke-PS2EXE .\InstallerVault.ps1 .\dist\InstallerVault.exe -noConsole
Invoke-PS2EXE .\InstallerVault.ps1 .\dist\InstallerVault.exe -noConsole -requireAdmin
Invoke-PS2EXE .\InstallerVault.ps1 .\dist\InstallerVault.exe -noConsole -iconFile .\app_icon.ico
```

## If the module alias is available
```powershell
ps2exe .\InstallerVault.ps1 .\dist\InstallerVault.exe -noConsole
```

## WinGet notes
- `winget download` downloads the installer and supports a custom folder with `--download-directory`. [web:32]
- Use exact package IDs when possible for cleaner downloads. [web:32]

## Screenshots 
- <img width="742" height="889" alt="uv1" src="https://github.com/user-attachments/assets/f3c791a1-f886-4e55-8c35-2e3842201604" />


## Release notes
- This release is intended for Windows.
- Build the EXE on Windows before distributing it.
- Some installers may still show vendor prompts even with silent-friendly flags.
