# Start Anaconda environment inside the curent Powershell session
# Written by Martin Dahl
[CmdletBinding()]
param (    
    [Parameter(Mandatory = $false, ParameterSetName = 'Env')]
    [string]$Env
)

$CondaPath = 'K:\Anaconda3\shell\condabin\conda-hook.ps1'
function ActivateConda {
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$Path
    )

    if ($Env -eq "") {
        Invoke-Expression -Command "& '$Path' ;conda activate"   
    }
    else {
        Invoke-Expression -Command "& '$Path' ;conda activate $Env"        
    }        
}

Clear-Host
Write-Host Activating Conda environment: $Env -ForegroundColor DarkYellow

ActivateConda $CondaPath