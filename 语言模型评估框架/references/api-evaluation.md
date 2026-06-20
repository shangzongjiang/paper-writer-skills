# API Evaluation

通过 API 评测 OpenAI、Anthropic 及其他基于 API 的语言模型指南。

## Overview

lm-evaluation-harness 通过统一的 `TemplateAPI` 接口支持对基于 API 的模型进行评测，可用于对以下模型进行基准测试：
- OpenAI 模型（GPT-4、GPT-3.5 等）
- Anthropic 模型（Claude 3、Claude 2 等）
- 本地 OpenAI 兼容 API
- 自定义 API 端点

**为何评测 API 模型**：
- 对闭源模型进行基准测试
- 将 API 模型与开源模型进行对比
- 验证 API 性能
- 追踪模型随时间的变化

## Supported API Models

| 提供商 | 模型类型 | 请求类型 | Logprobs |
|----------|------------|---------------|----------|
| OpenAI (completions) | `openai-completions` | 全部 | ✅ 是 |
| OpenAI (chat) | `openai-chat-completions` | 仅 `generate_until` | ❌ 否 |
| Anthropic (completions) | `anthropic-completions` | 全部 | ❌ 否 |
| Anthropic (chat) | `anthropic-chat` | 仅 `generate_until` | ❌ 否 |
| 本地（OpenAI 兼容）| `local-completions` | 取决于服务器 | 不定 |

**注意**：不支持 logprobs 的模型只能在生成任务上进行评测，无法用于困惑度或对数似然任务。

## OpenAI Models

### Setup

```bash
export OPENAI_API_KEY=sk-...
```

### Completion Models (Legacy)

**可用模型**：`davinci-002`、`babbage-002`

```bash
lm_eval --model openai-completions \
  --model_args model=davinci-002 \
  --tasks lambada_openai,hellaswag \
  --batch_size auto
```

**支持**：
- `generate_until`: ✅
- `loglikelihood`: ✅
- `loglikelihood_rolling`: ✅

### Chat Models

**可用模型**：`gpt-4`、`gpt-4-turbo`、`gpt-3.5-turbo`

```bash
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu,gsm8k,humaneval \
  --num_fewshot 5 \
  --batch_size auto
```

**支持**：
- `generate_until`: ✅
- `loglikelihood`: ❌（无 logprobs）
- `loglikelihood_rolling`: ❌

**重要提示**：Chat 模型不提供 logprobs，因此只能用于生成任务（MMLU、GSM8K、HumanEval），无法用于困惑度任务。

### Configuration Options

```bash
lm_eval --model openai-chat-completions \
  --model_args \
    model=gpt-4-turbo,\
    base_url=https://api.openai.com/v1,\
    num_concurrent=5,\
    max_retries=3,\
    timeout=60,\
    batch_size=auto
```

**参数说明**：
- `model`：模型标识符（必填）
- `base_url`：API 端点（默认：OpenAI）
- `num_concurrent`：并发请求数（默认：5）
- `max_retries`：失败请求重试次数（默认：3）
- `timeout`：请求超时时间，单位秒（默认：60）
- `tokenizer`：使用的分词器（默认：与模型匹配）
- `tokenizer_backend`：`"tiktoken"` 或 `"huggingface"`

### Cost Management

OpenAI 按 token 收费。运行前请先估算费用：

```python
# Rough estimate
num_samples = 1000
avg_tokens_per_sample = 500  # input + output
cost_per_1k_tokens = 0.01  # GPT-3.5 Turbo

total_cost = (num_samples * avg_tokens_per_sample / 1000) * cost_per_1k_tokens
print(f"Estimated cost: ${total_cost:.2f}")
```

**节省费用的建议**：
- 测试时使用 `--limit N`
- 先用 `gpt-3.5-turbo`，再考虑 `gpt-4`
- 将 `max_gen_toks` 设置为所需的最小值
- 尽量使用 `num_fewshot=0` 进行零样本评测

## Anthropic Models

### Setup

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

### Completion Models (Legacy)

```bash
lm_eval --model anthropic-completions \
  --model_args model=claude-2.1 \
  --tasks lambada_openai,hellaswag \
  --batch_size auto
```

### Chat Models (Recommended)

**可用模型**：`claude-3-5-sonnet-20241022`、`claude-3-opus-20240229`、`claude-3-sonnet-20240229`、`claude-3-haiku-20240307`

```bash
lm_eval --model anthropic-chat \
  --model_args model=claude-3-5-sonnet-20241022 \
  --tasks mmlu,gsm8k,humaneval \
  --num_fewshot 5 \
  --batch_size auto
```

**别名**：`anthropic-chat-completions`（与 `anthropic-chat` 相同）

### Configuration Options

```bash
lm_eval --model anthropic-chat \
  --model_args \
    model=claude-3-5-sonnet-20241022,\
    base_url=https://api.anthropic.com,\
    num_concurrent=5,\
    max_retries=3,\
    timeout=60
```

### Cost Management

Anthropic 定价（截至 2024 年）：
- Claude 3.5 Sonnet：输入 $3.00 / 1M tokens，输出 $15.00 / 1M tokens
- Claude 3 Opus：输入 $15.00 / 1M tokens，输出 $75.00 / 1M tokens
- Claude 3 Haiku：输入 $0.25 / 1M tokens，输出 $1.25 / 1M tokens

**经济实惠的策略**：
```bash
# Test on small sample first
lm_eval --model anthropic-chat \
  --model_args model=claude-3-haiku-20240307 \
  --tasks mmlu \
  --limit 100

# Then run full eval on best model
lm_eval --model anthropic-chat \
  --model_args model=claude-3-5-sonnet-20241022 \
  --tasks mmlu \
  --num_fewshot 5
```

## Local OpenAI-Compatible APIs

许多本地推理服务器提供与 OpenAI 兼容的 API（vLLM、Text Generation Inference、llama.cpp、Ollama）。

### vLLM Local Server

**启动服务器**：
```bash
vllm serve meta-llama/Llama-2-7b-hf \
  --host 0.0.0.0 \
  --port 8000
```

**评测**：
```bash
lm_eval --model local-completions \
  --model_args \
    model=meta-llama/Llama-2-7b-hf,\
    base_url=http://localhost:8000/v1,\
    num_concurrent=1 \
  --tasks mmlu,gsm8k \
  --batch_size auto
```

### Text Generation Inference (TGI)

**启动服务器**：
```bash
docker run --gpus all --shm-size 1g -p 8080:80 \
  ghcr.io/huggingface/text-generation-inference:latest \
  --model-id meta-llama/Llama-2-7b-hf
```

**评测**：
```bash
lm_eval --model local-completions \
  --model_args \
    model=meta-llama/Llama-2-7b-hf,\
    base_url=http://localhost:8080/v1 \
  --tasks hellaswag,arc_challenge
```

### Ollama

**启动服务器**：
```bash
ollama serve
ollama pull llama2:7b
```

**评测**：
```bash
lm_eval --model local-completions \
  --model_args \
    model=llama2:7b,\
    base_url=http://localhost:11434/v1 \
  --tasks mmlu
```

### llama.cpp Server

**启动服务器**：
```bash
./server -m models/llama-2-7b.gguf --host 0.0.0.0 --port 8080
```

**评测**：
```bash
lm_eval --model local-completions \
  --model_args \
    model=llama2,\
    base_url=http://localhost:8080/v1 \
  --tasks gsm8k
```

## Custom API Implementation

对于自定义 API 端点，请继承 `TemplateAPI`：

### Create `my_api.py`

```python
from lm_eval.models.api_models import TemplateAPI
import requests

class MyCustomAPI(TemplateAPI):
    """Custom API model."""

    def __init__(self, base_url, api_key, **kwargs):
        super().__init__(base_url=base_url, **kwargs)
        self.api_key = api_key

    def _create_payload(self, messages, gen_kwargs):
        """Create API request payload."""
        return {
            "messages": messages,
            "api_key": self.api_key,
            **gen_kwargs
        }

    def parse_generations(self, response):
        """Parse generation response."""
        return response.json()["choices"][0]["text"]

    def parse_logprobs(self, response):
        """Parse logprobs (if available)."""
        # Return None if API doesn't provide logprobs
        logprobs = response.json().get("logprobs")
        if logprobs:
            return logprobs["token_logprobs"]
        return None
```

### Register and Use

```python
from lm_eval import evaluator
from my_api import MyCustomAPI

model = MyCustomAPI(
    base_url="https://api.example.com/v1",
    api_key="your-key"
)

results = evaluator.simple_evaluate(
    model=model,
    tasks=["mmlu", "gsm8k"],
    num_fewshot=5,
    batch_size="auto"
)
```

## Comparing API and Open Models

### Side-by-Side Evaluation

```bash
# Evaluate OpenAI GPT-4
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu,gsm8k,hellaswag \
  --num_fewshot 5 \
  --output_path results/gpt4.json

# Evaluate open Llama 2 70B
lm_eval --model hf \
  --model_args pretrained=meta-llama/Llama-2-70b-hf,dtype=bfloat16 \
  --tasks mmlu,gsm8k,hellaswag \
  --num_fewshot 5 \
  --output_path results/llama2-70b.json

# Compare results
python scripts/compare_results.py \
  results/gpt4.json \
  results/llama2-70b.json
```

### Typical Comparisons

| 模型 | MMLU | GSM8K | HumanEval | 费用 |
|-------|------|-------|-----------|------|
| GPT-4 Turbo | 86.4% | 92.0% | 67.0% | $$$$ |
| Claude 3 Opus | 86.8% | 95.0% | 84.9% | $$$$ |
| GPT-3.5 Turbo | 70.0% | 57.1% | 48.1% | $$ |
| Llama 2 70B | 68.9% | 56.8% | 29.9% | 免费（自托管）|
| Mixtral 8x7B | 70.6% | 58.4% | 40.2% | 免费（自托管）|

## Best Practices

### Rate Limiting

请遵守 API 速率限制：
```bash
lm_eval --model openai-chat-completions \
  --model_args \
    model=gpt-4-turbo,\
    num_concurrent=3,\  # Lower concurrency
    timeout=120 \  # Longer timeout
  --tasks mmlu
```

### Reproducibility

将温度设置为 0 以获得确定性结果：
```bash
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu \
  --gen_kwargs temperature=0.0
```

或在采样时使用 `seed`：
```bash
lm_eval --model anthropic-chat \
  --model_args model=claude-3-5-sonnet-20241022 \
  --tasks gsm8k \
  --gen_kwargs temperature=0.7,seed=42
```

### Caching

API 模型会自动缓存响应以避免重复调用：
```bash
# First run: makes API calls
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu \
  --limit 100

# Second run: uses cache (instant, free)
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu \
  --limit 100
```

缓存位置：`~/.cache/lm_eval/`

### Error Handling

API 可能会出现故障，建议使用重试机制：
```bash
lm_eval --model openai-chat-completions \
  --model_args \
    model=gpt-4-turbo,\
    max_retries=5,\
    timeout=120 \
  --tasks mmlu
```

## Troubleshooting

### "Authentication failed"

检查 API 密钥：
```bash
echo $OPENAI_API_KEY  # Should print sk-...
echo $ANTHROPIC_API_KEY  # Should print sk-ant-...
```

### "Rate limit exceeded"

降低并发数：
```bash
--model_args num_concurrent=1
```

或在请求之间增加延迟。

### "Timeout error"

增大超时时间：
```bash
--model_args timeout=180
```

### "Model not found"

对于本地 API，请验证服务器是否正在运行：
```bash
curl http://localhost:8000/v1/models
```

### Cost Runaway

测试时使用 `--limit`：
```bash
lm_eval --model openai-chat-completions \
  --model_args model=gpt-4-turbo \
  --tasks mmlu \
  --limit 50  # Only 50 samples
```

## Advanced Features

### Custom Headers

```bash
lm_eval --model local-completions \
  --model_args \
    base_url=http://api.example.com/v1,\
    header="Authorization: Bearer token,X-Custom: value"
```

### Disable SSL Verification (Development Only)

```bash
lm_eval --model local-completions \
  --model_args \
    base_url=https://localhost:8000/v1,\
    verify_certificate=false
```

### Custom Tokenizer

```bash
lm_eval --model openai-chat-completions \
  --model_args \
    model=gpt-4-turbo,\
    tokenizer=gpt2,\
    tokenizer_backend=huggingface
```

## References

- OpenAI API: https://platform.openai.com/docs/api-reference
- Anthropic API: https://docs.anthropic.com/claude/reference
- TemplateAPI: `lm_eval/models/api_models.py`
- OpenAI models: `lm_eval/models/openai_completions.py`
- Anthropic models: `lm_eval/models/anthropic_llms.py`
