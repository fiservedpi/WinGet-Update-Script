## edit directory
$BaseDir = "C:\Users\Installers"
$CurrentDir = Join-Path $BaseDir "Current"
$ArchiveDir = Join-Path $BaseDir "Archive"
$LogFile = Join-Path $BaseDir "UpdateLog.txt"

# Add the apps you want to track using their exact WinGet IDs
$Apps = @(
    @{ Id = "AppControl.AppControl"; Name = "AppControl" }
    @{ Id = "Docker.DockerDesktop"; Name = "DockerDesktop" }
    @{ Id = "REALiX.HWiNFO"; Name = "HWiNFO64" }
    @{ Id = "Notepad++.Notepad++"; Name = "Notepad++" }
    @{ Id = "Microsoft.Office"; Name = "Microsoft365" }
    @{ Id = "Microsoft.OneDrive"; Name = "OneDrive" }
    @{ Id = "Nextcloud.NextcloudDesktop"; Name = "Nextcloud" }
    @{ Id = "PuTTY.PuTTY"; Name = "PuTTY" }
    @{ Id = "OpenJS.NodeJS.LTS"; Name = "NodeJS-LTS" }
    @{ Id = "Microsoft.VCRedist.2010.x64"; Name = "VC2010-x64" }
    @{ Id = "Microsoft.VCRedist.2008.x64"; Name = "VC2008-x64" }
    @{ Id = "RealVNC.VNCServer"; Name = "VNCServer" }
    @{ Id = "GoLang.Go"; Name = "Go" }
    @{ Id = "Oracle.JavaRuntimeEnvironment"; Name = "Java8" }
    @{ Id = "Corsair.iCUE.5"; Name = "iCUE5" }
    @{ Id = "Nvidia.PhysX"; Name = "PhysX" }
    @{ Id = "RealVNC.VNCViewer"; Name = "VNCViewer" }
    @{ Id = "Microsoft.VCRedist.2015+.x86"; Name = "VC2015-x86" }
    @{ Id = "Microsoft.VCRedist.2015+.x64"; Name = "VC2015-x64" }
    @{ Id = "Microsoft.VCRedist.2012.x86"; Name = "VC2012-x86" }
    @{ Id = "Microsoft.VCRedist.2012.x64"; Name = "VC2012-x64" }
    @{ Id = "Microsoft.VCRedist.2013.x86"; Name = "VC2013-x86" }
    @{ Id = "Microsoft.VCRedist.2013.x64"; Name = "VC2013-x64" }
    @{ Id = "Microsoft.VCRedist.2005.x86"; Name = "VC2005-x86" }
    @{ Id = "Microsoft.VCRedist.2008.x86"; Name = "VC2008-x86" }
    @{ Id = "Microsoft.VCRedist.2010.x86"; Name = "VC2010-x86" }
    @{ Id = "Rustlang.Rustup"; Name = "Rustup" }
    @{ Id = "Microsoft.VisualStudioCode"; Name = "VSCode-User" }
    @{ Id = "Python.Python.3.14"; Name = "Python314" }
    @{ Id = "Microsoft.AppInstaller"; Name = "AppInstaller" }
    @{ Id = "Microsoft.VisualStudio.BuildTools"; Name = "VSBuildTools" }
    @{ Id = "Microsoft.Edge"; Name = "Edge" }
    @{ Id = "VideoLAN.VLC"; Name = "VLC" }
    @{ Id = "WinSCP.WinSCP"; Name = "WinSCP" }
    @{ Id = "Microsoft.DotNet.DesktopRuntime.5"; Name = "DotNetDesktopRuntime5" }
    @{ Id = "Microsoft.WindowsSDK.10.0.26100"; Name = "WindowsSDK26100" }
    @{ Id = "Microsoft.WindowsTerminal"; Name = "WindowsTerminal" }
    @{ Id = "Microsoft.WSL"; Name = "WSL" }
)

function Show-InstallerBanner {
    $banner = @'
   ___           __        ____        __
  / _ )___  ____/ /__ ____/ / /  ___ _/ /_
 / _  / _ \/ __/  '_/(_-</ / _ \/ _ `/ __/
/____/\___/\__/_/\_\/___/_/_.__/\_,_/\__/

   Local Installer Vault Updater
'@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Log {
    param([string]$Message)

    $Stamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $Line = "[$Stamp] $Message"
    Write-Host $Line
    Add-Content -Path $LogFile -Value $Line
}

function Write-FunStatus {
    param(
        [string]$AppName,
        [ValidateSet("scan","download","archive","done","fail","start","finish")]
        [string]$Mode = "scan"
    )

    $msg = switch ($Mode) {
        "start"    { @(
            "[boot] Waking up the installer goblins ..."
            "[init] Opening the vault doors ..."
            "[sys ] Preparing download contraptions ..."
        ) }
        "scan"     { @(
            "[o_o] Thinking about $AppName ..."
            "[.-.] Checking the shelves for $AppName ..."
            "[+_+] Looking for fresh bits: $AppName ..."
        ) }
        "download" { @(
            "[>>>] Downloading $AppName ..."
            "[vvv] Pulling shiny new installer for $AppName ..."
            "[===] Beaming $AppName into the vault ..."
        ) }
        "archive"  { @(
            "[^^^] Tucking old $AppName into Archive ..."
            "[<_<] Moving dusty $AppName to cold storage ..."
        ) }
        "done"     { @(
            "[OK ] $AppName is up to date."
            "[^_^] $AppName secured in the vault."
        ) }
        "fail"     { @(
            "[!! ] $AppName had a problem."
            "[x_x] Could not update $AppName."
        ) }
        "finish"   { @(
            "[fin] Vault refresh complete."
            "[zzz] All installer goblins dismissed."
            "[end] Downloads complete. Archive tidy."
        ) }
    }

    Write-Host ($msg | Get-Random) -ForegroundColor Yellow
}

Show-InstallerBanner
New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null
New-Item -ItemType Directory -Force -Path $CurrentDir | Out-Null
New-Item -ItemType Directory -Force -Path $ArchiveDir | Out-Null

Write-FunStatus -Mode start
Write-Log "=== Starting Installer Downloads ==="

foreach ($App in $Apps) {
    $AppCurrent = Join-Path $CurrentDir $App.Name
    $AppArchive = Join-Path $ArchiveDir $App.Name

    New-Item -ItemType Directory -Force -Path $AppCurrent | Out-Null
    New-Item -ItemType Directory -Force -Path $AppArchive | Out-Null

    Write-FunStatus -AppName $App.Name -Mode scan
    Write-Log "Checking for updates: $($App.Name) ($($App.Id))"

    try {
        $Before = @()
        if (Test-Path $AppCurrent) {
            $Before = Get-ChildItem -Path $AppCurrent -File | Select-Object -ExpandProperty FullName
        }

        $wingetArgs = @(
            "download"
            "--id", $App.Id
            "--download-directory", $AppCurrent
            "--accept-source-agreements"
            "--accept-package-agreements"
            "--exact"
        )

        Write-FunStatus -AppName $App.Name -Mode download
        & winget @wingetArgs | Out-Null

        $Files = Get-ChildItem -Path $AppCurrent -File | Sort-Object LastWriteTime -Descending

        if ($Files.Count -gt 0) {
            $Newest = $Files[0]
            Write-Log " -> Current version is: $($Newest.Name)"

            if ($Files.Count -gt 1) {
                Write-FunStatus -AppName $App.Name -Mode archive

                for ($i = 1; $i -lt $Files.Count; $i++) {
                    $OldFile = $Files[$i]
                    $DestPath = Join-Path $AppArchive $OldFile.Name

                    if (Test-Path $DestPath) {
                        $TimeStamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
                        $DestPath = Join-Path $AppArchive "$($OldFile.BaseName)_$TimeStamp$($OldFile.Extension)"
                    }

                    Move-Item -Path $OldFile.FullName -Destination $DestPath -Force
                    Write-Log " -> Moved old version to Archive: $($OldFile.Name)"
                }
            }

            Write-FunStatus -AppName $App.Name -Mode done
        }
        else {
            Write-FunStatus -AppName $App.Name -Mode fail
            Write-Log " -> WARNING: Download failed or no file found for $($App.Name)."
        }
    }
    catch {
        Write-FunStatus -AppName $App.Name -Mode fail
        Write-Log " -> ERROR updating $($App.Name): $($_.Exception.Message)"
    }
}

Write-FunStatus -Mode finish
Write-Log "=== Installer Update Complete ==="