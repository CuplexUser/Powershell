# A simplesemi static ffmpeg HEVC, 2 pass encoder script 
# Written by Martin Dahl 2023
# ffmpeg -i "concat:DJI_0613.MP4|DJI_0614.MP4|DJI_0615.MP4" -c copy ..\DJI_0615_13-15.MP4
# DJI_0613.MP4    3671010
# DJI_0614.MP4    3671011
# DJI_0615.MP4    1935923

[CmdletBinding()]
param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]
    $SourceFile = "",

    [Parameter(Position = 1, Mandatory = $true)]
    [string]
    $OutputFile = "",

    [Parameter(Position = 2, Mandatory = $false)]
    [string]
    $BitRate = "10091k"
)

# kBit/s
# $BitRate = "10091k"

# Set-Location F:\DroneVideosToProcess
# $currentDir = ($PWD).Path
$currentDir = Get-Location

if ([string]::IsNullOrEmpty($SourceFile))
{
    Write-Host "The InFile param can not be empty" -ForegroundColor Yellow
    exit
}

if (-not(Test-Path -Path $SourceFile )) 
{
    Write-Host "InputFile: $SourceFile"
    Write-Host "The InFile path does not exist" -ForegroundColor Yellow
    exit
}

if ([string]::IsNullOrEmpty($OutputFile))
{
    Write-Host "The OutFile param can not be empty" -ForegroundColor Yellow
    exit 
}


function EncodeVideo
{
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$InFile,
        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$OutFile
    )

    try
    {       
        if (Test-Path -Path $InFile)
        {
            $inFile = $InFile
        }
        else
        {
            $inFile = Get-ChildItem -Path "$PWD\$InFile" | Select-Object -Property FullName -ExpandProperty FullName

            if (-not(Test-Path -Path $inFile)) 
            {
                Write-Host "Unable to locate the input file: $inFile" -ForegroundColor Red
                exit
            }
        } 
   
        Write-Host "Starting encoding job on the file '$inFile'"  -ForegroundColor Gray
        Write-Host "Running Pass-1" 
        $outFile = $OutFile      

        if ($outFile -eq "")
        {
            Write-Host "Output File path must be defined" -ForegroundColor Yellow
            exit
        }

        ffmpeg -hide_banner -hwaccel cuda -i $inFile -map 0:0 -c:v hevc_nvenc -trellis 0 -preset:v slow -keyint_min 300 -g 600 -me_method star -bf -1 -refs 3 -r 29.97 -pix_fmt yuv420p -metadata title="Drone flight" -metadata album_artist="Martin Dahl" -aspect 16:9 -b:v $BitRate -x265-params pass=1 -an -f mp4 NUL        

        Write-Host "Running Pass-2"        
        ffmpeg -hide_banner -hwaccel cuda -i $inFile -map 0:0 -c:v hevc_nvenc -trellis 0 -preset:v slow -keyint_min 300 -g 600 -me_method star -bf -1 -refs 3 -r 29.97 -pix_fmt yuv420p -metadata title="Drone flight" -metadata album_artist="Martin Dahl" -aspect 16:9 -b:v $BitRate -x265-params pass=2 -f mp4 -y $OutFile
    }
    catch
    {
        Write-Host "Unexpected error while running ffmpeg" -ForegroundColor Red
    }

    Write-Host "Encoding complete" -ForegroundColor Green}

Write-Host "InputFile: $SourceFile"
Write-Host "OutputFile: $OutputFile"
Write-Host "Bitrate is set to $BitRate"

$prompt = Read-Host "Continue with encoding? (Y/n)"
if (($prompt -eq "y") -or ($prompt -eq "") )
{
    $inPath = Join-Path -Path $currentDir -ChildPath $SourceFile
    $outPath = Join-Path -Path $currentDir -ChildPath $OutputFile

    Write-Host "Full Path: " -ForegroundColor White

    EncodeVideo -InFile $inPath -OutFile $outPath    
}
else 
{
    Write-Host "Canceled encoding" -ForegroundColor Magenta
}