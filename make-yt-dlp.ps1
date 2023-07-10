# Build script for yt-dlp. Requires Anaconda3 install
# Written by Martin Dahl 2022, Updated 2023

Write-Host 'Instructions on how to build YouTubeDownloader\yt-dlp' -ForegroundColor yellow
Write-Host 'cd D:\GitHub-Repositories\yt-dlp'
Write-Host 'python -m pip install -U pyinstaller -r requirements.txt'
Write-Host 'python devscripts/make_lazy_extractors.py'
Write-Host 'python pyinst.py'


function MakeApp
{    
    Param(
        [Parameter(Position = 0, Mandatory = $true)]
        [bool]
        $PerformBuild
    )
    
    if ($PerformBuild) 
    {
        try
        {
            Push-Location "D:\GitHub-Repositories\yt-dlp"
            
            git switch -
            git pull
            $tagVersion = git describe --abbrev=0 --tags
            git checkout $tagVersion
            Invoke-Expression "python -m pip install -U pyinstaller -r requirements.txt" 
            Invoke-Expression "python devscripts/make_lazy_extractors.py"
            Invoke-Expression "python pyinst.py"            

            if (Test-Path -Path "D:\Applications\YouTubeDownloader\yt-dlp.exe.old")
            {
                Write-Host "rm D:\Applications\YouTubeDownloader\yt-dlp.exe.old" -ForegroundColor Magenta
            }        
        }
        catch
        {
            Write-Host "Something went wrong"
            Write-Host "Please make sure that the Conda Environment is active"
        }
        finally
        {
            Pop-Location
        }

        Write-Host "mv 'D:\Applications\YouTubeDownloader\yt-dlp.exe'" "'D:\Applications\YouTubeDownloader\yt-dlp.exe.old'" -ForegroundColor Green
        Write-Host "mv 'D:\GitHub-Repositories\yt-dlp\dist\yt-dlp.exe'" "'D:\Applications\YouTubeDownloader\yt-dlp.exe'" -ForegroundColor Green
    }
    else
    {
        Write-Information -Message "Not performing build"
    }    
}


if (-not(Test-Path -Path "D:\GitHub-Repositories\yt-dlp"))
{
    Write-Host "The directory 'D:\GitHub-Repositories\yt-dlp' is missing, aborting build" -ForegroundColor Red
    exit 1
}

$activateCondaEnv = Read-Host -Prompt 'Activate Conda Environment? (y/n*)'
if ($activateCondaEnv -eq 'y')
{
    .("K:\Anaconda3\shell\condabin\conda-hook.ps1") 
    conda activate github
}

$responce = Read-Host -Prompt 'Run build now? (y*/n)'
$build = ($responce -ne 'n')

# Make Build Function call
MakeApp -PerformBuild $build