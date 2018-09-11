# PowerShell

## Overview

In this directory is a collection of bits of PowerShell that are useful in SQL Server

Using PowerShell combined with SQL Server Management Objects (SMO) gives you great versatility in what you can do, especially when using it in SQL Agent job steps.

## SMO

What is SMO, some may ask?

SMO gives you easy access to the _properties_ of the server and objects it contains (databases, views, jobs, availibility groups etc., etc.). These are the things that you would normally have to write nasty queries on system tables to get the information you require - like _is this instance the primary replica of a given availabilty group?_.

You also use SMO if you want to programatically script out database objects to files. I use this technique a lot for keeping a git repo up to date with changes I may have made within SSMS, by creating a manually executed job that scripts the objects I need to the repo folder in the file system.

The basic syntax for referencing SMO in a script is as follows

```powershell
# If running in SQL Agent, the following gets set to the current instance
# Else you can just supply a known instance
$instance = '$(ESCAPE_NONE(SRVR))'

# Load SMO assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

# Connect to the instance
$server = New-Object Microsoft.SqlServer.Management.Smo.Server ($instance)
```

For those who understand object-oriented programming, SMO is arranged as an object graph. This object graph more or less matches the tree you see in Object Explorer within SSMS, i.e. `$server.Databases` will return a collection of SMO database objects, one for each database on the instance.

Every SMO object has a `Parent` property for backward navigation. If you have a SMO database object, it's parent is the server object, and similarly a table object's parent is the containing database object.

## SQL Agent

SQL Agent provides a number of 'tokens' that will evaluate to information about the instance the job is running on and other environmental factors, and some of these you will find used in the scripts herein. See [this reference](https://docs.microsoft.com/en-us/sql/ssms/agent/use-tokens-in-job-steps) for a list.

Beware however of a gotcha when using PowerShell in SQL jobs is that PowerShell bracketed interpolation does not work due to the fact that the syntax is the same as that for including tokens. When SQL Agent preprocesses your script looking for tokens, it will mistake interpolations for tokens and fail as the token won't be found.

The following would work in regular PowerShell, but fail if it is part of a PowerShell job step in SQL Server:

```powershell
# Regular string interpolation

$a_string = 'John'
$interpolated_string = "Hello $($a_string), how are you?"

```

```powershell
# In SQL agent, it's necessary to do it old-skool

$a_string = 'John'
$interpolated_string = "Hello " + $a_string + ", how are you?"
```

