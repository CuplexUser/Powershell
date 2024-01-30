# Start Anaconda environment inside the curent Powershell session
# Written by Martin Dahl 2024

[CmdletBinding(DefaultParameterSetName = 'ExcludeUserPath',
    SupportsShouldProcess = $false,
    PositionalBinding = $false,    
    ConfirmImpact = 'Medium')]
[Alias()]
[OutputType([String])]
param (
    [Parameter(ParameterSetName = 'ExcludeUserPath', Position = 0, Mandatory = $false)]
    [switch]$ExcludeUserPath = $false,
    [Parameter(ParameterSetName = 'ListCurrentPath', Position = 1, Mandatory = $false)]
    [switch]$ListCurrentPath = $false    
)

function Update-EnvPath
{
    if ($ListCurrentPath)
    {
        Clear-Host
        Write-Host "The current Powershell environment Path"  -ForegroundColor White

        Write-Host "-----------------------------------------------------------------------------------------"  -ForegroundColor Gray

        foreach ($line in $ENV:PATH.split(";"))
        {
            Write-Host $line -ForegroundColor White
        }
        
        Write-Host "-----------------------------------------------------------------------------------------"  -ForegroundColor Gray
        return
    }

    if ($ExcludeUserPath)
    {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        Write-Host "Powershell environment path for the current session has been updated from System Environment Path ONLY" -ForegroundColor DarkYellow        
    }
    else
    {
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")        
        Write-Host "Powershell environment path for the current session has been updated from System Env Path and User Env Path" -ForegroundColor Green
    }    
}

Update-EnvPath