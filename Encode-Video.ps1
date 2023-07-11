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
    $BitRate = "10091k",

    [Parameter(Position = 3, Mandatory = $false)]
    [double]
    $FrameRate = 29.97,

    [Parameter(Position = 4, Mandatory = $false)]
    [switch]
    $EncodeWithAudio = $false,

    [Parameter(Position = 5, Mandatory = $false)]
    [switch]
    $ShowEncoderCommands = $false
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

function Get-CustomErrorMessage($ErrorMessage)
{ 
    $FinalErrorMessage = "Error occurred: $ErrorMessage" 
    return $FinalErrorMessage
}

# Extract the filename from a full path of a file that does not exist yet
function Get-MetadataTitle
{
    param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String]$FullPath
    )
    $title = $FullPath.Split("\");
    $title = $title[$title.Length - 1]


    $ext = $title.LastIndexOf(".")
    $extLength = $title.Length - $ext
    if ($ext -gt 1)
    {
        $title = $title.Substring(0, $title.Length - $extLength)
    }

    return $title
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

        $TempDir = $ENV:TEMP
        $outFile = $OutFile 
        Write-Host "Starting encoding job on the file '$inFile'"  -ForegroundColor Gray

        if ($outFile -eq "")
        {
            Write-Host "Output File path must be defined" -ForegroundColor Yellow
            exit
        }
        
        $title = Get-MetadataTitle -FullPath $OutFile
        Write-Host "Setting metadata Title to: $title" -ForegroundColor DarkYellow
        $AudioParams = ""
        $Mapping = "-map 0:0"
        
        if ($EncodeWithAudio)
        {
            $AudioParams = "-c:a aac -b:a 128k -ac 2 -profile:a aac_main"
            $Mapping = "-map 0:0 -map 0:1"
        }

        Write-Host "Running First Encoder pass" -ForegroundColor Green
        $command = "ffmpeg -hide_banner -hwaccel cuda -i `"$inFile`" -map 0:0 -c:v hevc_nvenc -trellis 2 -threads auto -preset:v slow -tune hq -keyint_min 300 -g 1000 -me_method umh -bf 3 -refs 0 -r $FrameRate -pix_fmt yuv420p -metadata title='$title' -metadata year='$([System.DateTime]::Today.Year)' -aspect 16:9 -b:v $BitRate -pass 1 -passlogfile '$TempDir\encodeScript_ffmpeg_multipass' -an -f mp4 NUL"
        
        if ($ShowEncoderCommands) 
        {
            Write-Host $command -ForegroundColor DarkGray
        }
        Invoke-Expression -Command $command

        Write-Host "Running Second Encoder Pass" -ForegroundColor Green   
        $command = "ffmpeg -hide_banner -hwaccel cuda -i `"$inFile`" $Mapping -c:v hevc_nvenc -trellis 2 -threads auto -preset:v slow -tune hq -keyint_min 300 -g 1000 -me_method umh -bf 3 -refs 0 -r $FrameRate -pix_fmt yuv420p $AudioParams -metadata title='$title' -metadata year='$([System.DateTime]::Today.Year)' -aspect 16:9 -b:v $BitRate -pass 2 -passlogfile '$TempDir\encodeScript_ffmpeg_multipass' -f mp4 -y '$OutFile'"

        if ($ShowEncoderCommands) 
        {
            Write-Host $command -ForegroundColor DarkGray
        }
        Invoke-Expression -Command $command
        Write-Host "Encoding Completed" -ForegroundColor Green

    }
    catch
    {
        Write-Host "Unexpected error while running ffmpeg" -ForegroundColor Red
        Write-Host Get-CustomErrorMessage($ErrorMessage) -ForegroundColor Yellow
    }

    Write-Host "Encoding complete" -ForegroundColor Green
}

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