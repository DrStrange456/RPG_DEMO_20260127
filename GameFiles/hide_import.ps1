# Use the folder this script resides in
$projectPath = $PSScriptRoot

# Hide existing .import files immediately
Get-ChildItem -Path $projectPath -Recurse -Filter *.import |
    ForEach-Object { $_.Attributes = 'Hidden' }

# Create watcher
$watcher = New-Object IO.FileSystemWatcher
$watcher.Path = $projectPath
$watcher.Filter = "*.import"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher Created -Action {
    attrib +h $Event.SourceEventArgs.FullPath
}

#Write-Host "Watching for new .import files in $projectPath..."
#while ($true) { Start-Sleep 5 }