Clear-Host
Write-Host "server.py with all options and input arguments" -ForegroundColor Blue
Write-Host  "
usage: server.py [-h] [--notebook] [--chat] [--character CHARACTER] [--model MODEL] [--lora LORA [LORA ...]] [--model-dir MODEL_DIR] [--lora-dir LORA_DIR] [--model-menu] [--no-stream]
                 [--settings SETTINGS] [--extensions EXTENSIONS [EXTENSIONS ...]] [--verbose] [--loader LOADER] [--cpu] [--auto-devices] [--gpu-memory GPU_MEMORY [GPU_MEMORY ...]]
                 [--cpu-memory CPU_MEMORY] [--disk] [--disk-cache-dir DISK_CACHE_DIR] [--load-in-8bit] [--bf16] [--no-cache] [--xformers] [--sdp-attention] [--trust-remote-code]
                 [--load-in-4bit] [--compute_dtype COMPUTE_DTYPE] [--quant_type QUANT_TYPE] [--use_double_quant] [--threads THREADS] [--n_batch N_BATCH] [--no-mmap] [--mlock]
                 [--cache-capacity CACHE_CAPACITY] [--n-gpu-layers N_GPU_LAYERS] [--n_ctx N_CTX] [--llama_cpp_seed LLAMA_CPP_SEED] [--wbits WBITS] [--model_type MODEL_TYPE]
                 [--groupsize GROUPSIZE] [--pre_layer PRE_LAYER [PRE_LAYER ...]] [--checkpoint CHECKPOINT] [--monkey-patch] [--quant_attn] [--warmup_autotune] [--fused_mlp]
                 [--gptq-for-llama] [--autogptq] [--triton] [--no_inject_fused_attention] [--no_inject_fused_mlp] [--no_use_cuda_fp16] [--desc_act] [--gpu-split GPU_SPLIT]
                 [--max_seq_len MAX_SEQ_LEN] [--compress_pos_emb COMPRESS_POS_EMB] [--flexgen] [--percent PERCENT [PERCENT ...]] [--compress-weight] [--pin-weight [PIN_WEIGHT]]
                 [--deepspeed] [--nvme-offload-dir NVME_OFFLOAD_DIR] [--local_rank LOCAL_RANK] [--rwkv-strategy RWKV_STRATEGY] [--rwkv-cuda-on] [--listen] [--listen-host LISTEN_HOST]
                 [--listen-port LISTEN_PORT] [--share] [--auto-launch] [--gradio-auth GRADIO_AUTH] [--gradio-auth-path GRADIO_AUTH_PATH] [--api] [--api-blocking-port API_BLOCKING_PORT]
                 [--api-streaming-port API_STREAMING_PORT] [--public-api] [--multimodal-pipeline MULTIMODAL_PIPELINE]

options:
  -h, --help                                 show this help message and exit
  --notebook                                 Launch the web UI in notebook mode, where the output is written to the same text box as the input.
  --chat                                     Launch the web UI in chat mode with a style similar to the Character.AI website.
  --character CHARACTER                      The name of the character to load in chat mode by default.
  --model MODEL                              Name of the model to load by default.
  --lora LORA [LORA ...]                     The list of LoRAs to load. If you want to load more than one LoRA, write the names separated by spaces.
  --model-dir MODEL_DIR                      Path to directory with all the models
  --lora-dir LORA_DIR                        Path to directory with all the loras
  --model-menu                               Show a model menu in the terminal when the web UI is first launched.
  --no-stream                                Don't stream the text output in real time.
  --settings SETTINGS                        Load the default interface settings from this yaml file. See settings-template.yaml for an example. If you create a file called settings.yaml,
                                             this file will be loaded by default without the need to use the --settings flag.
  --extensions EXTENSIONS [EXTENSIONS ...]   The list of extensions to load. If you want to load more than one extension, write the names separated by spaces.
  --verbose                                  Print the prompts to the terminal.
  --loader LOADER                            Choose the model loader manually, otherwise, it will get autodetected. Valid options: transformers, autogptq, gptq-for-llama, exllama,
                                             exllama_hf, llamacpp, rwkv, flexgen
  --cpu                                      Use the CPU to generate text. Warning: Training on CPU is extremely slow.
  --auto-devices                             Automatically split the model across the available GPU(s) and CPU.
  --gpu-memory GPU_MEMORY [GPU_MEMORY ...]   Maximum GPU memory in GiB to be allocated per GPU. Example: --gpu-memory 10 for a single GPU, --gpu-memory 10 5 for two GPUs. You can also set
                                             values in MiB like --gpu-memory 3500MiB.
  --cpu-memory CPU_MEMORY                    Maximum CPU memory in GiB to allocate for offloaded weights. Same as above.
  --disk                                     If the model is too large for your GPU(s) and CPU combined, send the remaining layers to the disk.
  --disk-cache-dir DISK_CACHE_DIR            Directory to save the disk cache to. Defaults to "cache".
  --load-in-8bit                             Load the model with 8-bit precision (using bitsandbytes).
  --bf16                                     Load the model with bfloat16 precision. Requires NVIDIA Ampere GPU.
  --no-cache                                 Set use_cache to False while generating text. This reduces the VRAM usage a bit at a performance cost.
  --xformers                                 Use xformer's memory efficient attention. This should increase your tokens/s.
  --sdp-attention                            Use torch 2.0's sdp attention.
  --trust-remote-code                        Set trust_remote_code=True while loading a model. Necessary for ChatGLM and Falcon.
  --load-in-4bit                             Load the model with 4-bit precision (using bitsandbytes).
  --compute_dtype COMPUTE_DTYPE              compute dtype for 4-bit. Valid options: bfloat16, float16, float32.
  --quant_type QUANT_TYPE                    quant_type for 4-bit. Valid options: nf4, fp4.
  --use_double_quant                         use_double_quant for 4-bit.
  --threads THREADS                          Number of threads to use.
  --n_batch N_BATCH                          Maximum number of prompt tokens to batch together when calling llama_eval.
  --no-mmap                                  Prevent mmap from being used.
  --mlock                                    Force the system to keep the model in RAM.
  --cache-capacity CACHE_CAPACITY            Maximum cache capacity. Examples: 2000MiB, 2GiB. When provided without units, bytes will be assumed.
  --n-gpu-layers N_GPU_LAYERS                Number of layers to offload to the GPU.
  --n_ctx N_CTX                              Size of the prompt context.
  --llama_cpp_seed LLAMA_CPP_SEED            Seed for llama-cpp models. Default 0 (random)
  --wbits WBITS                              Load a pre-quantized model with specified precision in bits. 2, 3, 4 and 8 are supported.
  --model_type MODEL_TYPE                    Model type of pre-quantized model. Currently LLaMA, OPT, and GPT-J are supported.
  --groupsize GROUPSIZE                      Group size.
  --pre_layer PRE_LAYER [PRE_LAYER ...]      The number of layers to allocate to the GPU. Setting this parameter enables CPU offloading for 4-bit models. For multi-gpu, write the numbers
                                             separated by spaces, eg --pre_layer 30 60.
  --checkpoint CHECKPOINT                    The path to the quantized checkpoint file. If not specified, it will be automatically detected.
  --monkey-patch                             Apply the monkey patch for using LoRAs with quantized models.
  --quant_attn                               (triton) Enable quant attention.
  --warmup_autotune                          (triton) Enable warmup autotune.
  --fused_mlp                                (triton) Enable fused mlp.
  --gptq-for-llama                           DEPRECATED
  --autogptq                                 DEPRECATED
  --triton                                   Use triton.
  --no_inject_fused_attention                Do not use fused attention (lowers VRAM requirements).
  --no_inject_fused_mlp                      Triton mode only: Do not use fused MLP (lowers VRAM requirements).
  --no_use_cuda_fp16                         This can make models faster on some systems.
  --desc_act                                 For models that don't have a quantize_config.json, this parameter is used to define whether to set desc_act or not in BaseQuantizeConfig.
  --gpu-split GPU_SPLIT                      Comma-separated list of VRAM (in GB) to use per GPU device for model layers, e.g. 20,7,7
  --max_seq_len MAX_SEQ_LEN                  Maximum sequence length.
  --compress_pos_emb COMPRESS_POS_EMB        Positional embeddings compression factor. Should typically be set to max_seq_len / 2048.
  --flexgen                                  DEPRECATED
  --percent PERCENT [PERCENT ...]            FlexGen: allocation percentages. Must be 6 numbers separated by spaces (default: 0, 100, 100, 0, 100, 0).
  --compress-weight                          FlexGen: activate weight compression.
  --pin-weight [PIN_WEIGHT]                  FlexGen: whether to pin weights (setting this to False reduces CPU memory by 20%).
  --deepspeed                                Enable the use of DeepSpeed ZeRO-3 for inference via the Transformers integration.
  --nvme-offload-dir NVME_OFFLOAD_DIR        DeepSpeed: Directory to use for ZeRO-3 NVME offloading.
  --local_rank LOCAL_RANK                    DeepSpeed: Optional argument for distributed setups.
  --rwkv-strategy RWKV_STRATEGY              RWKV: The strategy to use while loading the model. Examples: "cpu fp32", "cuda fp16", "cuda fp16i8".
  --rwkv-cuda-on                             RWKV: Compile the CUDA kernel for better performance.
  --listen                                   Make the web UI reachable from your local network.
  --listen-host LISTEN_HOST                  The hostname that the server will use.
  --listen-port LISTEN_PORT                  The listening port that the server will use.
  --share                                    Create a public URL. This is useful for running the web UI on Google Colab or similar.
  --auto-launch                              Open the web UI in the default browser upon launch.
  --gradio-auth GRADIO_AUTH                  set gradio authentication like "username:password"; or comma-delimit multiple like "u1:p1,u2:p2,u3:p3"
  --gradio-auth-path GRADIO_AUTH_PATH        Set the gradio authentication file path. The file should contain one or more user:password pairs in this format: "u1:p1,u2:p2,u3:p3"
  --api                                      Enable the API extension.
  --api-blocking-port API_BLOCKING_PORT      The listening port for the blocking API.
  --api-streaming-port API_STREAMING_PORT    The listening port for the streaming API.
  --public-api                               Create a public URL for the API using Cloudfare.
  --multimodal-pipeline MULTIMODAL_PIPELINE  The multimodal pipeline to use. Examples: llava-7b, llava-13b." 