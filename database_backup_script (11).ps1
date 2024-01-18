Clear-Host
$Server = "localhost\SQLEXPRESS"
$BackupFolder = "D:\databasebackups"  # Change the backup folder path to D drive
$Date = Get-Date -Format MM-dd-yyyy-HH-mm-ss  # Include time in the date format
Write-Output "Date: $($Date)"
Write-Output "Taking backup from $($Server) and saving file(s) to $($BackupFolder)."
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$s = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Server
$Databases = $s.Databases

ForEach ($Database in $Databases) {
    If (($Database.Name -ne "tempdb") -and ($Database.Name -ne "master") -and ($Database.Name -ne "model") -and ($Database.Name -ne "msdb")) {
        $ZipFileName = "$BackupFolder\$($Database.Name)_Backup_$($Date).zip"
        $FilePath = "$BackupFolder\$($Database.Name)_db_$($Date).bak"
        
        Backup-SqlDatabase -ServerInstance $Server -Database $Database.Name -BackupFile $FilePath

        Compress-Archive -Path $FilePath -DestinationPath $ZipFileName -Force

        Remove-Item -Path $FilePath -Force  # Remove the .bak file after zipping

        Write-Output "Backup file for $($Database.Name) zipped and renamed: $($ZipFileName)"
    }
}

Write-Output "Database backup complete."
