[CmdletBinding(DefaultParameterSetName = 'BaseDir',
    SupportsShouldProcess = $false,
    PositionalBinding = $false,    
    ConfirmImpact = 'Medium')]
[Alias()]
[OutputType([String])]
PARAM ( 
    [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "BaseDir")]
    [string]$BaseDir = ".", 
    [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Depth")]
    [int]$Depth = 2, 
    [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "Maintenance")]
    [bool]$Maintenance = $false,

    [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "GitCommand")]    
    [ValidateNotNullOrEmpty()]
    [string]$GitCommand = "'pull'",
    [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "Help")]
    [switch]$Help = $false
)

# Set Error Action
$ErrorActionPreference = "Continue"

function Update-GithubRepos {     

    if ($Maintenance) {
        $Cmd = "pull & git maintenance run"
    }

    
    $Cmd = $GitCommand.Trim("'");        
    $gitFolderName = ".git"

    Write-Host "Starting gitPull on all subfolders with basedir: $BaseDir"
    # Finds all .git folders by givenPath
    $gitFolders = Get-ChildItem $BaseDir -Recurse -Depth $Depth -Force | Where-Object { $_.PSIsContainer -and $_.Name -eq $gitFolderName } | Select-Object FullName
    $folderCount = ($gitFolders | Measure-Object).Count
        
    Write-Host "Found '$folderCount' git repositories under '$BaseDir'" -foregroundColor "green"
    
    ForEach ($gitFolder in $gitFolders) {
    
        # Remove the ".git" folder from thePath 
        $folder = Split-Path $gitFolder.FullName   #-replace $gitFolderName, ""
    
        Write-Host "Performing git $Cmd in folder: '$folder'" -foregroundColor "green"
    
        # Go into the folder
        Push-Location $folder 
    
        #Perform the command within the folder
        Invoke-Expression "git $Cmd"
    
        # Go back to the original folder
        Pop-Location
            
    } 
        
    Write-Host "Completed batch run."
    Set-Location $BaseDir 
}

if ($Help) {
    Write-Host Usage: '$BaseDir' = "Default '.' , can be any physical path containing numersous git repositories. AuthenticateAsAdmin" -Depth "<recursion depth>" -Maintenance "Run maintinence on each pulled repo"
}
else {   
    Update-GithubRepos
}