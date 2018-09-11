<#
    .SYNOPSIS
        Script all agent jobs of a given category to the file system
        e.g. into a Git repo folder.

        Add this script as an agent job that you can run after making changes
        to the jobs it scripts.
#>

# Job categories to include
$jobCategories = @('MyCategory')

# Where to script to. Assumes the folder exists - which it should if it's a cloned repo.
$scriptFolder = 'C:\Temp\MyRepo\Jobs'

# Load SMO
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null

# Connect to this instance
$server = New-Object Microsoft.SqlServer.Management.Smo.Server '$(ESCAPE_NONE(SRVR))'

# Create a UTF-8 without BOM encoding
$encoding = New-Object System.Text.UTF8Encoding $false

# Iterate jobs, scripting them to individiual files in the target folder
$server.JobServer.Jobs |
Where-Object { $jobCategories -icontains $_.category } |
ForEach-Object {

    [System.IO.File]::WriteAllLines([IO.Path]::Combine($scriptFolder, ($_.Name + '.sql')), ($_.Script() | Out-String), $encoding)
}

