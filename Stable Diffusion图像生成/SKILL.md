---
name: Stable Diffusion图像生成
description: 通过 HuggingFace Diffusers 使用 Stable Diffusion 生成图像——文本生图、图像修复、图生图。
version: 1.0.0
author: Orchestra Research
license: MIT
tags: [图像生成, Stable Diffusion, Diffusers, 文本生图, 多模态, 计算机视觉]
dependencies: [diffusers>=0.30.0, transformers>=4.41.0, accelerate>=0.31.0, torch>=2.0.0]
---

# Stable Diffusion 图像生成

使用 HuggingFace Diffusers 库进行 Stable Diffusion 图像生成的全面指南。

## 适用场景与替代方案

**适合使用 Stable Diffusion 的场景：**
- 根据文本描述生成图像
- 图像到图像转换（风格迁移、增强）
- 图像修复（填充遮罩区域）
- 图像外绘（将图像延伸至边界之外）
- 创建现有图像的变体
- 构建自定义图像生成工作流

**主要特性：**
- **文本生图**：从自然语言提示词生成图像
- **图生图**：在文本引导下转换现有图像
- **图像修复**：用上下文感知内容填充遮罩区域
- **ControlNet**：添加空间条件（边缘、姿态、深度）
- **LoRA 支持**：高效微调与风格适配
- **多模型支持**：支持 SD 1.5、SDXL、SD 3.0、Flux

**建议改用替代方案的场景：**
- **DALL-E 3**：无 GPU 的 API 生成
- **Midjourney**：艺术风格化输出
- **Imagen**：Google Cloud 集成
- **Leonardo.ai**：基于 Web 的创意工作流

## 快速开始

### 安装

```bash
pip install diffusers transformers accelerate torch
pip install xformers  # 可选：内存高效注意力机制
```

### 基础文本生图

```python
from diffusers import DiffusionPipeline
import torch

# 加载流水线（自动检测模型类型）
pipe = DiffusionPipeline.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    torch_dtype=torch.float16
)
pipe.to("cuda")

# 生成图像
image = pipe(
    "A serene mountain landscape at sunset, highly detailed",
    num_inference_steps=50,
    guidance_scale=7.5
).images[0]

image.save("output.png")
```

### 使用 SDXL（更高质量）

```python
from diffusers import AutoPipelineForText2Image
import torch

pipe = AutoPipelineForText2Image.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=torch.float16,
    variant="fp16"
)
pipe.to("cuda")

# 启用内存优化
pipe.enable_model_cpu_offload()

image = pipe(
    prompt="A futuristic city with flying cars, cinematic lighting",
    height=1024,
    width=1024,
    num_inference_steps=30
).images[0]
```

## 架构概述

### 三支柱设计

Diffusers 围绕三个核心组件构建：

```
Pipeline（编排层）
├── Model（神经网络）
│   ├── UNet / Transformer（噪声预测）
│   ├── VAE（潜变量编解码）
│   └── Text Encoder（CLIP/T5）
└── Scheduler（去噪算法）
```

### 流水线推理流程

```
文本提示词 → 文本编码器 → 文本嵌入
                               ↓
随机噪声 → [去噪循环] ← Scheduler
                ↓
           预测噪声
                ↓
           VAE 解码器 → 最终图像
```

## 核心概念

### 流水线

流水线负责编排完整工作流：

| 流水线 | 用途 |
|----------|---------|
| `StableDiffusionPipeline` | 文本生图（SD 1.x/2.x） |
| `StableDiffusionXLPipeline` | 文本生图（SDXL） |
| `StableDiffusion3Pipeline` | 文本生图（SD 3.0） |
| `FluxPipeline` | 文本生图（Flux 模型） |
| `StableDiffusionImg2ImgPipeline` | 图生图 |
| `StableDiffusionInpaintPipeline` | 图像修复 |

### 调度器

调度器控制去噪过程：

| 调度器 | 步数 | 质量 | 适用场景 |
|-----------|-------|---------|----------|
| `EulerDiscreteScheduler` | 20-50 | 好 | 默认选择 |
| `EulerAncestralDiscreteScheduler` | 20-50 | 好 | 更多变化 |
| `DPMSolverMultistepScheduler` | 15-25 | 优秀 | 快速高质量 |
| `DDIMScheduler` | 50-100 | 好 | 确定性输出 |
| `LCMScheduler` | 4-8 | 好 | 极速生成 |
| `UniPCMultistepScheduler` | 15-25 | 优秀 | 快速收敛 |

### 切换调度器

```python
from diffusers import DPMSolverMultistepScheduler

# 切换至更快的调度器
pipe.scheduler = DPMSolverMultistepScheduler.from_config(
    pipe.scheduler.config
)

# 使用更少步数生成
image = pipe(prompt, num_inference_steps=20).images[0]
```

## 生成参数

### 关键参数

| 参数 | 默认值 | 说明 |
|-----------|---------|-------------|
| `prompt` | 必填 | 目标图像的文本描述 |
| `negative_prompt` | 无 | 图像中需要避免的内容 |
| `num_inference_steps` | 50 | 去噪步数（越多质量越高） |
| `guidance_scale` | 7.5 | 提示词遵循度（通常为 7-12） |
| `height`, `width` | 512/1024 | 输出尺寸（8 的倍数） |
| `generator` | 无 | 用于可复现性的 Torch 生成器 |
| `num_images_per_prompt` | 1 | 批次大小 |

### 可复现生成

```python
import torch

generator = torch.Generator(device="cuda").manual_seed(42)

image = pipe(
    prompt="A cat wearing a top hat",
    generator=generator,
    num_inference_steps=50
).images[0]
```

### 负面提示词

```python
image = pipe(
    prompt="Professional photo of a dog in a garden",
    negative_prompt="blurry, low quality, distorted, ugly, bad anatomy",
    guidance_scale=7.5
).images[0]
```

## 图生图

在文本引导下转换现有图像：

```python
from diffusers import AutoPipelineForImage2Image
from PIL import Image

pipe = AutoPipelineForImage2Image.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    torch_dtype=torch.float16
).to("cuda")

init_image = Image.open("input.jpg").resize((512, 512))

image = pipe(
    prompt="A watercolor painting of the scene",
    image=init_image,
    strength=0.75,  # 转换程度（0-1）
    num_inference_steps=50
).images[0]
```

## 图像修复

填充遮罩区域：

```python
from diffusers import AutoPipelineForInpainting
from PIL import Image

pipe = AutoPipelineForInpainting.from_pretrained(
    "runwayml/stable-diffusion-inpainting",
    torch_dtype=torch.float16
).to("cuda")

image = Image.open("photo.jpg")
mask = Image.open("mask.png")  # 白色 = 修复区域

result = pipe(
    prompt="A red car parked on the street",
    image=image,
    mask_image=mask,
    num_inference_steps=50
).images[0]
```

## ControlNet

添加空间条件以实现精确控制：

```python
from diffusers import StableDiffusionControlNetPipeline, ControlNetModel
import torch

# 加载 Canny 边缘条件的 ControlNet
controlnet = ControlNetModel.from_pretrained(
    "lllyasviel/control_v11p_sd15_canny",
    torch_dtype=torch.float16
)

pipe = StableDiffusionControlNetPipeline.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    controlnet=controlnet,
    torch_dtype=torch.float16
).to("cuda")

# 使用 Canny 边缘图像作为控制条件
control_image = get_canny_image(input_image)

image = pipe(
    prompt="A beautiful house in the style of Van Gogh",
    image=control_image,
    num_inference_steps=30
).images[0]
```

### 可用的 ControlNet 类型

| ControlNet | 输入类型 | 适用场景 |
|------------|------------|----------|
| `canny` | 边缘图 | 保留结构 |
| `openpose` | 姿态骨架 | 人体姿态 |
| `depth` | 深度图 | 3D 感知生成 |
| `normal` | 法线图 | 表面细节 |
| `mlsd` | 线段 | 建筑线条 |
| `scribble` | 草图 | 草图生图 |

## LoRA 适配器

加载微调的风格适配器：

```python
from diffusers import DiffusionPipeline

pipe = DiffusionPipeline.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    torch_dtype=torch.float16
).to("cuda")

# 加载 LoRA 权重
pipe.load_lora_weights("path/to/lora", weight_name="style.safetensors")

# 使用 LoRA 风格生成
image = pipe("A portrait in the trained style").images[0]

# 调整 LoRA 强度
pipe.fuse_lora(lora_scale=0.8)

# 卸载 LoRA
pipe.unload_lora_weights()
```

### 多个 LoRA

```python
# 加载多个 LoRA
pipe.load_lora_weights("lora1", adapter_name="style")
pipe.load_lora_weights("lora2", adapter_name="character")

# 为每个设置权重
pipe.set_adapters(["style", "character"], adapter_weights=[0.7, 0.5])

image = pipe("A portrait").images[0]
```

## 内存优化

### 启用 CPU 卸载

```python
# 模型 CPU 卸载——不使用时将模型移至 CPU
pipe.enable_model_cpu_offload()

# 顺序 CPU 卸载——更激进，速度较慢
pipe.enable_sequential_cpu_offload()
```

### 注意力切片

```python
# 分块计算注意力以减少内存占用
pipe.enable_attention_slicing()

# 或指定特定块大小
pipe.enable_attention_slicing("max")
```

### xFormers 内存高效注意力

```python
# 需要安装 xformers 包
pipe.enable_xformers_memory_efficient_attention()
```

### 大图像的 VAE 切片

```python
# 分块解码潜变量以处理大图像
pipe.enable_vae_slicing()
pipe.enable_vae_tiling()
```

## 模型变体

### 加载不同精度

```python
# FP16（GPU 推荐）
pipe = DiffusionPipeline.from_pretrained(
    "model-id",
    torch_dtype=torch.float16,
    variant="fp16"
)

# BF16（精度更好，需要 Ampere+ GPU）
pipe = DiffusionPipeline.from_pretrained(
    "model-id",
    torch_dtype=torch.bfloat16
)
```

### 加载特定组件

```python
from diffusers import UNet2DConditionModel, AutoencoderKL

# 加载自定义 VAE
vae = AutoencoderKL.from_pretrained("stabilityai/sd-vae-ft-mse")

# 配合流水线使用
pipe = DiffusionPipeline.from_pretrained(
    "stable-diffusion-v1-5/stable-diffusion-v1-5",
    vae=vae,
    torch_dtype=torch.float16
)
```

## 批量生成

高效生成多张图像：

```python
# 多个提示词
prompts = [
    "A cat playing piano",
    "A dog reading a book",
    "A bird painting a picture"
]

images = pipe(prompts, num_inference_steps=30).images

# 每个提示词生成多张图像
images = pipe(
    "A beautiful sunset",
    num_images_per_prompt=4,
    num_inference_steps=30
).images
```

## 常用工作流

### 工作流 1：高质量生成

```python
from diffusers import StableDiffusionXLPipeline, DPMSolverMultistepScheduler
import torch

# 1. 加载带优化的 SDXL
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=torch.float16,
    variant="fp16"
)
pipe.to("cuda")
pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)
pipe.enable_model_cpu_offload()

# 2. 使用质量设置生成
image = pipe(
    prompt="A majestic lion in the savanna, golden hour lighting, 8k, detailed fur",
    negative_prompt="blurry, low quality, cartoon, anime, sketch",
    num_inference_steps=30,
    guidance_scale=7.5,
    height=1024,
    width=1024
).images[0]
```

### 工作流 2：快速原型开发

```python
from diffusers import AutoPipelineForText2Image, LCMScheduler
import torch

# 使用 LCM 实现 4-8 步生成
pipe = AutoPipelineForText2Image.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=torch.float16
).to("cuda")

# 加载 LCM LoRA 以快速生成
pipe.load_lora_weights("latent-consistency/lcm-lora-sdxl")
pipe.scheduler = LCMScheduler.from_config(pipe.scheduler.config)
pipe.fuse_lora()

# 约 1 秒内完成生成
image = pipe(
    "A beautiful landscape",
    num_inference_steps=4,
    guidance_scale=1.0
).images[0]
```

## 常见问题

**CUDA 内存不足：**
```python
# 启用内存优化
pipe.enable_model_cpu_offload()
pipe.enable_attention_slicing()
pipe.enable_vae_slicing()

# 或使用更低精度
pipe = DiffusionPipeline.from_pretrained(model_id, torch_dtype=torch.float16)
```

**黑图或噪声图像：**
```python
# 检查 VAE 配置
# 必要时绕过安全检查器
pipe.safety_checker = None

# 确保数据类型一致
pipe = pipe.to(dtype=torch.float16)
```

**生成速度慢：**
```python
# 使用更快的调度器
from diffusers import DPMSolverMultistepScheduler
pipe.scheduler = DPMSolverMultistepScheduler.from_config(pipe.scheduler.config)

# 减少步数
image = pipe(prompt, num_inference_steps=20).images[0]
```

## 参考文档

- **[高级用法](references/advanced-usage.md)** - 自定义流水线、微调、部署
- **[故障排查](references/troubleshooting.md)** - 常见问题与解决方案

## 参考资源

- **文档**：https://huggingface.co/docs/diffusers
- **仓库**：https://github.com/huggingface/diffusers
- **模型中心**：https://huggingface.co/models?library=diffusers
- **Discord**：https://discord.gg/diffusers

---
如未收到具体问题，直接询问："您在使用 Stable Diffusion 时想构建什么或调试什么问题？请分享您的代码、配置或报错信息。"
