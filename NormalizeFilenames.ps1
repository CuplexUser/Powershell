# Written by Martin Dahl 2023 v1.00
# Specifies a path to one or more locations. Wildcards are permitted.
# $nonascii = [regex] "[^\x00-\x7F]"

[CmdletBinding(
    DefaultParameterSetName = 'DirectoryPath',
    SupportsShouldProcess = $false) ]
Param(
    [Parameter(        
        Mandatory = $false,    
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Peformes everything the same but does not rename any files, instead a debug row is printed foreach match")]    
    [switch] $DryRun,

    [Parameter(       
        Mandatory = $false,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "A regular expression matching the characters to be removed in a filename. For example '[\s\d\W]{1,}'")]
    [string] $RegExpMatchString,

    [Parameter(
        ParameterSetName = "DirectoryPath",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Path to the directory where you want to rename files. If not supplied the current working directoiry will be used.")] 
    [string] $DirectoryPath = ".",
    
    [Parameter(       
        ParameterSetName = "IncludeFilter",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Wildcard filter. Default set to *.*")]
    [string] $IncludeFilter,

    [Parameter(       
        ParameterSetName = "ExcluideFilter",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "ExcluideFilter in wildcard format")]
    [string] $ExcludeFilter = "*.ps1"

    # [Parameter(
    #     Position = 0, 
    #     ParameterSetName = "Help",
    #     HelpMessage = "Shows the help page.")]
    #     [switch][System.Boolean] $ShowHelpPage
)

# function Convert-DiacriticCharacters
# {
#     param(
#         [string]$inputString
#     )
#     [string]$formD = $inputString.Normalize(
#         [System.text.NormalizationForm]::FormD
#     )
#     $stringBuilder = New-Object System.Text.StringBuilder
#     for ($i = 0; $i -lt $formD.Length; $i++)
#     {
#         $unicodeCategory = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($formD[$i])
#         $nonSPacingMark = [System.Globalization.UnicodeCategory]::NonSpacingMark
#         if ($unicodeCategory -ne $nonSPacingMark)
#         {
#             $stringBuilder.Append($formD[$i]) | Out-Null
#         }
#     }
#     $stringBuilder.ToString().Normalize([System.text.NormalizationForm]::FormC)
# }

function  Remove-RegexpChars
{
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$Name
    )

    $extention = [System.IO.Path]::GetExtension($name)
    $fileName = $Name.Substring(0, $Name.Length - $extention.Length)
   
    return ($fileName -replace $RegExpMatchString).Trim() + $extention    
}

function Remove-Diacritics
{
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$Name
    )

    $chars = $Name.Normalize([System.Text.NormalizationForm]::FormD).GetEnumerator().Where{ 

        [System.Char]::GetUnicodeCategory($_) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark

    }
    $Name = (-join $chars).Normalize([System.Text.NormalizationForm]::FormC)

    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''    
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    return ($Name -replace $re)
}

function RenameFilesSelected
{    
    param(
        [System.Collections.Generic.Dictionary[string, string]]$renameDict
    )

    $renameCount = 0
    foreach ($key in $renameDict.Keys)
    {
        $fileName = $key
        $newName = ($renameDict[$key]).Trim()
        
        if (-not(Test-Path -Path $fileName))
        {
            $fileName = "$($DirectoryPath.Trim("*\"))\$fileName"
        }

        if ($DryRun)
        {
            Write-Host "(Dry run) Renaming: $key" -ForegroundColor Yellow
            Write-Host "(Dry run) New filenam: $newName" -ForegroundColor Yellow               
        }
        else
        {
            Write-Host "Renaming: $fileName" -ForegroundColor Green
            Write-Host "New filenam:  $newName" -ForegroundColor Green
            Rename-Item -Path $fileName -NewName $newName
            Write-Host "-----------------------------" -ForegroundColor Gray
        }

        $renameCount = $renameCount + 1
        
    }

    Write-Host "Files renamed: $renameCount" -ForegroundColor Blue
}


function GetFileListFromPath
{   
    [OutputType([System.Collections.Generic.Dictionary[string, string]])]    
    $dictionary = New-Object 'System.Collections.Generic.Dictionary[[string],[string]]'

    $wildcard = "*.*" 
    if (-not [string]::IsNullOrEmpty($IncludeFilter))
    {
        $wildcard = $IncludeFilter
    }
    
    $list = Get-ChildItem -Path "$DirectoryPath\*" -Include $wildcard -Exclude $ExcludeFilter | Select-Object Name -ExpandProperty Name
    $doRegexpRename = $RegExpMatchString -ne ""

    foreach ($item in $list)
    {     
        $AsciiName = ""
        if ($doRegexpRename)
        {
            $AsciiName = Remove-RegexpChars -Name $item             
        }
        else
        {
            $AsciiName = Remove-Diacritics -Name $item            
        }

        Write-Host "AsciiName = $AsciiName"       
     
        if ($item -ne $AsciiName)
        {
            $dictionary.Add($item, $AsciiName)
        }                
    }

    return $dictionary
}

function VerifyAndSetAppParameters
{
    if ([string]::IsNullOrEmpty($DirectoryPath))
    {
        $DirectoryPath = (Get-Location).Path        
    }

    if (-not(Test-Path -Path $DirectoryPath))
    {
        Write-Host "Invalid Directory: $DirectoryPath" -ForegroundColor Red
        return $false
    }
    
    if (-not(Test-Path -Path $DirectoryPath))
    {
        Write-Host "Ther provided Dir Path is not valid" -ForegroundColor Red
        return $false
    }

    if (-not [string]::IsNullOrEmpty($FileTypeFilter))
    {
        Write-Host "The filter parameter was set to: '$FileTypeFilter'"
    }    

    return $true
}

function Main
{
    Write-Host "Validating params"

    if (-not (VerifyAndSetAppParameters))
    {
        Write-Host "Cant continue. Aborting Script" -ForegroundColor DarkRed
        exit 0
    }

    #Files to process
    $fileTranslationDict = GetFileListFromPath

    Write-Host "Found" $fileTranslationDict.Count items
    Write-Host "Begining to itterate filenames"
    RenameFilesSelected $fileTranslationDict

    Write-Host "Completed" -ForegroundColor DarkGray
}

Write-Host "Starting up."
Main



