try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName System.Windows.Forms

    $ErrorActionPreference = "Stop"

    $BaseDir = "C:\Installers"
    $CurrentDir = Join-Path $BaseDir "Current"
    $ArchiveDir = Join-Path $BaseDir "Archive"

    function Write-UiLog {
        param(
            [string]$Message,
            [System.Windows.Controls.TextBox]$LogTextBox
        )

        $stamp = Get-Date -Format "HH:mm:ss"
        $line = "[$stamp] $Message"
        Write-Host $line

        if ($LogTextBox) {
            $LogTextBox.AppendText($line + [Environment]::NewLine)
            $LogTextBox.ScrollToEnd()
        }
    }

    function Refresh-Ui {
        param($Window)
        $Window.Dispatcher.Invoke([Action]{}, [Windows.Threading.DispatcherPriority]::Background)
    }

    function Get-WingetApps {
        $wingetOut = winget list --source winget
        $apps = @()
        $started = $false

        foreach ($line in $wingetOut) {
            if ($line -match '^---') {
                $started = $true
                continue
            }

            if ($started -and -not [string]::IsNullOrWhiteSpace($line)) {
                $parts = $line -split '\s{2,}'
                if ($parts.Count -ge 3) {
                    $name = $parts[0].Trim()
                    $id = $parts[1].Trim()

                    if ($id -match '^[A-Za-z0-9\.\+\-_]+$') {
                        $apps += [PSCustomObject]@{
                            IsChecked = $true
                            AppName   = $name
                            AppId     = $id
                        }
                    }
                }
            }
        }

        return $apps | Sort-Object AppName -Unique
    }

    function Show-SplashScreen {
        [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Installer Vault"
        Width="520" Height="300"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        ResizeMode="NoResize"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False">
    <Border Background="#141218" CornerRadius="28" BorderBrush="#2B2930" BorderThickness="1">
        <Grid Margin="28">
            <StackPanel VerticalAlignment="Center">
                <Border Width="80" Height="80" CornerRadius="24" HorizontalAlignment="Center" Margin="0,0,0,18"
                        Background="#4F378B">
                    <Grid>
                        <TextBlock Text="download"
                                   Foreground="#EADDFF"
                                   FontSize="18"
                                   FontWeight="SemiBold"
                                   HorizontalAlignment="Center"
                                   VerticalAlignment="Center"/>
                    </Grid>
                </Border>

                <TextBlock Text="Installer Vault"
                           Foreground="#E6E0E9"
                           FontSize="28"
                           FontWeight="SemiBold"
                           HorizontalAlignment="Center"/>

                <TextBlock Text="Loading your installer library..."
                           Foreground="#CAC4D0"
                           FontSize="14"
                           HorizontalAlignment="Center"
                           Margin="0,12,0,0"/>

                <TextBlock Text="Material-style dark theme, local backups, and WinGet package selection."
                           Foreground="#938F99"
                           FontSize="12"
                           TextAlignment="Center"
                           TextWrapping="Wrap"
                           Margin="28,16,28,0"/>
            </StackPanel>
        </Grid>
    </Border>
</Window>
"@

        $reader = New-Object System.Xml.XmlNodeReader $xaml
        $window = [Windows.Markup.XamlReader]::Load($reader)

        $timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [TimeSpan]::FromMilliseconds(1400)
        $timer.Add_Tick({
            $timer.Stop()
            $window.Close()
        })

        $window.Add_MouseLeftButtonDown({
            $timer.Stop()
            $window.Close()
        })

        $timer.Start()
        $window.ShowDialog() | Out-Null
    }

    Show-SplashScreen

    $apps = Get-WingetApps
    if (-not $apps -or $apps.Count -eq 0) {
        [System.Windows.MessageBox]::Show("No WinGet packages found on this PC.", "Installer Vault", "OK", "Error") | Out-Null
        return
    }

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Installer Vault"
        Height="900" Width="760"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        ResizeMode="NoResize"
        AllowsTransparency="True"
        Background="Transparent">
    <Border Background="#141218" CornerRadius="28" BorderBrush="#2B2930" BorderThickness="1">
        <Grid Margin="18">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="190"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid Grid.Row="0" Margin="0,0,0,14">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal">
                    <Border Width="56" Height="56" CornerRadius="18" Background="#4F378B" Margin="0,0,14,0">
                        <Grid>
                            <TextBlock Text="inventory_2"
                                       Foreground="#EADDFF"
                                       FontSize="15"
                                       FontWeight="SemiBold"
                                       HorizontalAlignment="Center"
                                       VerticalAlignment="Center"/>
                        </Grid>
                    </Border>

                    <StackPanel>
                        <TextBlock Text="Installer Vault"
                                   Foreground="#E6E0E9"
                                   FontSize="24"
                                   FontWeight="SemiBold"/>
                        <TextBlock Text="Select installed WinGet apps to keep backed up locally"
                                   Foreground="#CAC4D0"
                                   FontSize="13"/>
                    </StackPanel>
                </StackPanel>

                <Button Name="CloseBtn"
                        Grid.Column="1"
                        Width="40" Height="40"
                        Content="close"
                        Background="#211F26"
                        Foreground="#CAC4D0"
                        BorderBrush="#49454F"
                        BorderThickness="1"/>
            </Grid>

            <Border Grid.Row="1"
                    Background="#211F26"
                    CornerRadius="20"
                    BorderBrush="#49454F"
                    BorderThickness="1"
                    Padding="14"
                    Margin="0,0,0,14">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel>
                        <TextBlock Text="Detected apps"
                                   Foreground="#E6E0E9"
                                   FontSize="15"
                                   FontWeight="SemiBold"/>
                        <TextBlock Text="Surface container styling inspired by Material 3."
                                   Foreground="#CAC4D0"
                                   FontSize="12"
                                   Margin="0,2,0,0"/>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal">
                        <Button Name="SelectAllBtn"
                                Content="Select all"
                                Width="100" Height="34"
                                Margin="0,0,10,0"
                                Background="#2B2930"
                                Foreground="#E6E0E9"
                                BorderBrush="#49454F"
                                BorderThickness="1"/>
                        <Button Name="ClearAllBtn"
                                Content="Clear all"
                                Width="100" Height="34"
                                Background="#2B2930"
                                Foreground="#E6E0E9"
                                BorderBrush="#49454F"
                                BorderThickness="1"/>
                    </StackPanel>
                </Grid>
            </Border>

            <ListView Grid.Row="2"
                      Name="AppListView"
                      Background="Transparent"
                      BorderThickness="0"
                      ScrollViewer.HorizontalScrollBarVisibility="Disabled">
                <ListView.ItemContainerStyle>
                    <Style TargetType="ListViewItem">
                        <Setter Property="Background" Value="#2B2930"/>
                        <Setter Property="Margin" Value="0,0,0,10"/>
                        <Setter Property="Padding" Value="14"/>
                        <Setter Property="BorderBrush" Value="#49454F"/>
                        <Setter Property="BorderThickness" Value="1"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ListViewItem">
                                    <Border Background="{TemplateBinding Background}"
                                            BorderBrush="{TemplateBinding BorderBrush}"
                                            BorderThickness="{TemplateBinding BorderThickness}"
                                            CornerRadius="18">
                                        <ContentPresenter Margin="{TemplateBinding Padding}"/>
                                    </Border>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </ListView.ItemContainerStyle>

                <ListView.ItemTemplate>
                    <DataTemplate>
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <CheckBox Grid.Column="0"
                                      IsChecked="{Binding IsChecked}"
                                      Margin="0,0,14,0"
                                      VerticalAlignment="Center">
                                <CheckBox.LayoutTransform>
                                    <ScaleTransform ScaleX="1.22" ScaleY="1.22"/>
                                </CheckBox.LayoutTransform>
                            </CheckBox>

                            <StackPanel Grid.Column="1">
                                <TextBlock Text="{Binding AppName}"
                                           Foreground="#E6E0E9"
                                           FontSize="15"
                                           FontWeight="SemiBold"/>
                                <TextBlock Text="{Binding AppId}"
                                           Foreground="#CAC4D0"
                                           FontSize="12"
                                           Margin="0,4,0,0"/>
                            </StackPanel>
                        </Grid>
                    </DataTemplate>
                </ListView.ItemTemplate>
            </ListView>

            <Border Grid.Row="3"
                    Background="#211F26"
                    CornerRadius="20"
                    BorderBrush="#49454F"
                    BorderThickness="1"
                    Padding="14"
                    Margin="0,14,0,14">
                <StackPanel>
                    <TextBlock Name="ProgressLabel"
                               Text="Waiting to start..."
                               Foreground="#E6E0E9"
                               FontSize="13"
                               Margin="0,0,0,10"/>
                    <Grid Height="18">
                        <Border Background="#2B2930" CornerRadius="9"/>
                        <ProgressBar Name="MainProgressBar"
                                     Minimum="0"
                                     Maximum="100"
                                     Value="0"
                                     Height="18"
                                     BorderThickness="0"
                                     Background="Transparent"
                                     Foreground="#D0BCFF"/>
                    </Grid>
                </StackPanel>
            </Border>

            <Border Grid.Row="4"
                    Background="#211F26"
                    CornerRadius="20"
                    BorderBrush="#49454F"
                    BorderThickness="1"
                    Padding="12"
                    Margin="0,0,0,14">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <TextBlock Text="Live log"
                               Foreground="#E6E0E9"
                               FontSize="14"
                               FontWeight="SemiBold"
                               Margin="0,0,0,8"/>
                    <TextBox Grid.Row="1"
                             Name="LogTextBox"
                             Background="#141218"
                             Foreground="#E6E0E9"
                             BorderBrush="#49454F"
                             BorderThickness="1"
                             FontFamily="Consolas"
                             FontSize="12"
                             IsReadOnly="True"
                             AcceptsReturn="True"
                             VerticalScrollBarVisibility="Auto"
                             TextWrapping="Wrap"/>
                </Grid>
            </Border>

            <Grid Grid.Row="5">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock Name="FooterText"
                           Text="Ready."
                           Foreground="#CAC4D0"
                           FontSize="12"
                           VerticalAlignment="Center"/>

                <StackPanel Grid.Column="1" Orientation="Horizontal">
                    <Button Name="CancelBtn"
                            Content="Cancel"
                            Width="110" Height="42"
                            Margin="0,0,10,0"
                            Background="#2B2930"
                            Foreground="#E6E0E9"
                            BorderBrush="#49454F"
                            BorderThickness="1"/>
                    <Button Name="StartBtn"
                            Content="Start backup"
                            Width="160" Height="42"
                            Background="#4F378B"
                            Foreground="#EADDFF"
                            FontWeight="SemiBold"
                            BorderBrush="#4F378B"
                            BorderThickness="0"/>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)

    $AppListView = $window.FindName("AppListView")
    $SelectAllBtn = $window.FindName("SelectAllBtn")
    $ClearAllBtn = $window.FindName("ClearAllBtn")
    $StartBtn = $window.FindName("StartBtn")
    $CancelBtn = $window.FindName("CancelBtn")
    $CloseBtn = $window.FindName("CloseBtn")
    $MainProgressBar = $window.FindName("MainProgressBar")
    $ProgressLabel = $window.FindName("ProgressLabel")
    $FooterText = $window.FindName("FooterText")
    $LogTextBox = $window.FindName("LogTextBox")

    $AppListView.ItemsSource = $apps
    $script:IsRunning = $false

    $SelectAllBtn.Add_Click({
        foreach ($app in $apps) { $app.IsChecked = $true }
        $AppListView.Items.Refresh()
        $FooterText.Text = "All apps selected."
    })

    $ClearAllBtn.Add_Click({
        foreach ($app in $apps) { $app.IsChecked = $false }
        $AppListView.Items.Refresh()
        $FooterText.Text = "All apps cleared."
    })

    $CloseBtn.Add_Click({
        if ($script:IsRunning) {
            [System.Windows.MessageBox]::Show("A backup is currently running. Please wait for it to finish.", "Installer Vault", "OK", "Warning") | Out-Null
            return
        }
        $window.Close()
    })

    $CancelBtn.Add_Click({
        if ($script:IsRunning) {
            [System.Windows.MessageBox]::Show("A backup is currently running. Please wait for it to finish.", "Installer Vault", "OK", "Warning") | Out-Null
            return
        }
        $window.Close()
    })

    $StartBtn.Add_Click({
        if ($script:IsRunning) { return }

        $selected = @($apps | Where-Object { $_.IsChecked })
        if ($selected.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Select at least one app first.", "Installer Vault", "OK", "Warning") | Out-Null
            return
        }

        $script:IsRunning = $true
        $StartBtn.IsEnabled = $false
        $SelectAllBtn.IsEnabled = $false
        $ClearAllBtn.IsEnabled = $false
        $MainProgressBar.Value = 0
        $LogTextBox.Clear()

        New-Item -ItemType Directory -Force -Path $BaseDir | Out-Null
        New-Item -ItemType Directory -Force -Path $CurrentDir | Out-Null
        New-Item -ItemType Directory -Force -Path $ArchiveDir | Out-Null

        Write-UiLog -Message "=== Starting Installer Downloads ===" -LogTextBox $LogTextBox
        $total = $selected.Count
        $index = 0

        foreach ($app in $selected) {
            $index++
            $percentBefore = [math]::Floor((($index - 1) / $total) * 100)
            $MainProgressBar.Value = $percentBefore
            $ProgressLabel.Text = "Downloading $($app.AppName) ($index of $total)..."
            $FooterText.Text = $app.AppId
            Refresh-Ui -Window $window

            $appCurrent = Join-Path $CurrentDir $app.AppId
            $appArchive = Join-Path $ArchiveDir $app.AppId
            New-Item -ItemType Directory -Force -Path $appCurrent | Out-Null
            New-Item -ItemType Directory -Force -Path $appArchive | Out-Null

            Write-UiLog -Message "Checking for updates: $($app.AppName) ($($app.AppId))" -LogTextBox $LogTextBox
            Refresh-Ui -Window $window

            try {
                $wingetArgs = @(
                    "download"
                    "--id", $app.AppId
                    "--download-directory", $appCurrent
                    "--accept-source-agreements"
                    "--accept-package-agreements"
                    "--exact"
                )

                & winget @wingetArgs | Out-Null

                $files = Get-ChildItem -Path $appCurrent -File | Sort-Object LastWriteTime -Descending
                if ($files.Count -gt 0) {
                    $newest = $files[0]
                    Write-UiLog -Message " -> Current version is: $($newest.Name)" -LogTextBox $LogTextBox

                    if ($files.Count -gt 1) {
                        $ProgressLabel.Text = "Archiving old files for $($app.AppName)..."
                        Refresh-Ui -Window $window

                        for ($i = 1; $i -lt $files.Count; $i++) {
                            $oldFile = $files[$i]
                            $destPath = Join-Path $appArchive $oldFile.Name

                            if (Test-Path $destPath) {
                                $timeStamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
                                $destPath = Join-Path $appArchive "$($oldFile.BaseName)_$timeStamp$($oldFile.Extension)"
                            }

                            Move-Item -Path $oldFile.FullName -Destination $destPath -Force
                            Write-UiLog -Message " -> Moved old version to Archive: $($oldFile.Name)" -LogTextBox $LogTextBox
                            Refresh-Ui -Window $window
                        }
                    }
                }
                else {
                    Write-UiLog -Message " -> WARNING: Download failed or no file found." -LogTextBox $LogTextBox
                }
            }
            catch {
                Write-UiLog -Message " -> ERROR updating $($app.AppName): $($_.Exception.Message)" -LogTextBox $LogTextBox
            }

            $percentAfter = [math]::Floor(($index / $total) * 100)
            $MainProgressBar.Value = $percentAfter
            $ProgressLabel.Text = "Completed $($app.AppName)"
            $FooterText.Text = "$index / $total complete"
            Refresh-Ui -Window $window
        }

        $MainProgressBar.Value = 100
        $ProgressLabel.Text = "All selected installers processed."
        $FooterText.Text = "Complete."
        Write-UiLog -Message "=== Installer Update Complete ===" -LogTextBox $LogTextBox

        $script:IsRunning = $false
        $StartBtn.IsEnabled = $true
        $SelectAllBtn.IsEnabled = $true
        $ClearAllBtn.IsEnabled = $true

        [System.Windows.MessageBox]::Show("Vault refresh complete! Selected installers were downloaded and archived.", "Installer Vault", "OK", "Information") | Out-Null
    })

    $window.Add_MouseLeftButtonDown({ $window.DragMove() })
    $window.ShowDialog() | Out-Null
}
catch {
    $msg = $_ | Out-String
    try {
        [System.Windows.Forms.MessageBox]::Show($msg, "Installer Vault Error", "OK", "Error") | Out-Null
    } catch {}
}