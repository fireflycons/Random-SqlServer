<#
    .SYNOPSIS
        For disciples of the formidable Ola Hallengren, these are for you :-)

        Replicate in PowerShell how to obtain the same paths for backups
        as computed by the Ola Hallengren DatabaseBackup procedure.

        Much simpler than doing it in SQL!
#>

function Get-OlaServerIdentifier
{
    <#
    .SYNOPSIS
        Use Ola Hallengren rules to generate path segments according to server configuration for a given database.

    .DESCRIPTION
        Path segments (both file and directory) for backup files are generated from various SQL Server configuration settings.

        If the database is part of an availability group, then the path segment is formed: Instance_Cluster_Name$Database_AG_Name
        If the database is not part of an AG, then it is instance name with any backslash replaced with $

    .PARAMETER SmoDatabase
        SMO Database to examine

    .OUTPUTS
        [string] Path segment
    #>
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.Database]$SmoDatabase
    )

    if ([string]::IsNullOrEmpty($SmoDatabase.AvailabilityGroupName))
    {
        # Standalone server or unsynced database
        $SmoDatabase.Parent.Name.Replace("\", "$")
    }
    else
    {
        # AG synced
        $SmoDatabase.Parent.ClusterName + "$" + $SmoDatabase.AvailabilityGroupName
    }
}

function Get-OlaBackupDirectory
{
    <#
    .SYNOPSIS
        Compute path to backup directory using Ola Hallengren rules

    .PARAMETER SmoDatabase
        SMO object identifying the database to operate on

    .PARAMETER BackupType
        Type of the backup, e.g. FULL. Appended to the end of the returned path.

    .PARAMETER BackupRoot
        Optional user supplied root path to backup folder structure

    .OUTPUTS
        [string] Path to directory where this database's backups should go

    .EXAMPLE
        $smoDatabase = $smoServer.Databases["MyDatabase"]
        $backupPath = Get-OlaBackupDirectory -SmoDatabase $smoDatabase -BackupRoot \\myserver\backups -BackupType FULL

    .NOTES
        Backup root directory determined as follows
        1. If user supplied BackupRoot argument, use that
        2. Use SQL server default
    #>

    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.Database]$SmoDatabase,

        [ValidateSet('FULL', 'DIFF', 'LOG')]
        [string]$BackupType,

        [string]$BackupRoot
    )

    $smoServer = $smoDatabase.Parent

    $rootDir = Invoke-Command -NoNewScope -ScriptBlock {
        if ([string]::IsNullOrEmpty($BackupRoot))
        {
            # Fall back to SQL server default
            $smoServer.BackupDirectory
        }
        else
        {
            # Return user-supplied value
            $BackupRoot
        }
    }

    # Append the Ola path segment to the backup root
    $rootDir = Join-Path $rootDir (Get-OlaServerIdentifier -SmoDatabase $SmoDatabase)

    # Append the backup type to this and return the full directory path.
    Join-Path $rootDir (Join-Path $SmoDatabase.Name $BackupType)
}

