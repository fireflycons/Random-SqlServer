<#
    .SYNOPSIS
        Detect if the current instance is the primary replica of a given availability group.

    .DESCRIPTION
        You might use this in an agent job you have in all replicas of the AG,
        but you only want the logic to run if the current instance is the primary.
#>

# The availibility group to check
$AgName = 'MyAvailabilityGroup'

# Load SMO
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null

# Connect to this instance
$server = New-Object Microsoft.SqlServer.Management.Smo.Server '$(ESCAPE_NONE(SRVR))'

# If the AG is found and we are primary, then the result is True; else False
$isPrimaryReplica = ($server.AvailabilityGroups | Where-Object { $_.Name -eq $AgName } | Select-Object -ExpandProperty LocalReplicaRole) -eq 'Primary'

if ($isPrimaryReplica)
{
    # Perform some action
}
