# Powershell script for starting the Text Generation Web UI with a 7b model

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false, Position = 0)]
    [switch]$MultiModal = $false,

    [Parameter(Mandatory = $false, Position = 1)]
    [switch]$ListModels = $false,

    [Parameter(Mandatory = $false, Position = 0)]
    [switch]$ShowHelp = $false,

    [Parameter(Mandatory = $false, Position = 2)]
    [switch]$MonkeyPatch = $false,

    [Parameter(Mandatory = $false, Position = 3)]
    [string]$ModelName = "TheBloke_Nous-Hermes-13B-GPTQ",
    
    [Parameter(Mandatory = $false, Position = 4)]
    [string]$Loader = "gptq-for-llama"    
)

# llava-7b
#$mmPipeLine = 'llava-7b' 
$mmPipeLine = 'minigpt4-7b' 

function PromptActivateConda
{
    $p = Read-Host "Do you want to activate Anaconda environment? (y/n*)"
    
    if ($p -eq 'y')
    {
        start-conda -env textgen
    }
}


function StartLLM
{
    PromptActivateConda   

    $modelParam = "--model $ModelName --loader $Loader --wbits 4 --groupsize 128"
    if ($MonkeyPatch) 
    {
        $modelParam += " --monkey-patch"
    }
    Write-Host "ModelParam: $modelParam"

    if ($MultiModal)
    {
        Write-Host "Starting up with Multi Modal"  -ForegroundColor DarkYellow
        Invoke-Expression "python server.py --auto-devices --xformers --chat --quant_attn --extensions long_term_memory multimodal --multimodal-pipeline $mmPipeLine --load-in-4bit $modelParam --auto-launch"
        
    }
    else
    {
        Write-Host "Starting up"  -ForegroundColor DarkYellow
        #Write-Host ERROR  -ForegroundColor Red
        Invoke-Expression "python server.py --auto-devices --xformers --chat --quant_attn --extensions long_term_memory send_pictures --load-in-4bit $modelParam --auto-launch"
    }     
}

if ($ListModels){
    $models = Get-ChildItem -Path .\text-generation-webui\models -Directory | Select-Object Name -ExpandProperty Name

    Write-Host "Installed moddels:" -ForegroundColor DarkGreen
    foreach($model in $models){
        Write-Host $model -ForegroundColor White
    }
    
    exit 0
}

if ($ShowHelp)
{
    try {
        Invoke-Command -ScriptBlock {
            .\Usage.ps1
        } 
    }
    catch {
        Write-Host "Unable to invoke Usage script, verify that a file named 'Usage.ps1' exists in the current dir $PWD" -ForegroundColor Red
    }    

    exit 0
}

Write-Host "Starting Text Generation WebUI"  -ForegroundColor DarkGreen
try
{
    Push-Location text-generation-webui
    StartLLM
}
catch
{
    Write-Host "Script excecution ended prematurly" -ForegroundColor Red
}
finally
{
    Pop-Location
}


# Write-Host Executing the following command:  -ForegroundColor DarkCyan
# Write-Host "python server.py --auto-devices --chat --extensions silero_tts multiModal openai send_pictures xformers --multiModal-pipeline llava-7b --load-in-4bit --model TheBloke_Wizard-Vicuna-7B-Uncensored-GPTQ --wbits 4 --groupsize 128" -ForegroundColor DarkYellow 
# python server.py --auto-devices --chat --extensions silero_tts multiModal openai send_pictures xformers --multiModal-pipeline llava-7b --load-in-4bit --model TheBloke_Wizard-Vicuna-7B-Uncensored-GPTQ --wbits 4 --groupsize 128  

# start-conda -env textgen google_translate
# ./main -t 10 -ngl 32 -m Wizard-Vicuna-30B-Uncensored.ggmlv3.q5_0.bin --color -c 2048 --temp 0.7 --repeat_penalty 1.1 -n -1 -p "### Instruction: Write a story about llamas\n### Response:"

#  python server.py --auto-devices --chat --quant_attn --extensions xformers whisper_stt send_pictures --load-in-4bit model_type = Llama --model TheBloke_Wizard-Vicuna-30B-Uncensored-GPTQ --wbits 4 --groupsize None 