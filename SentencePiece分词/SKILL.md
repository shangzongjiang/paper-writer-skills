---
name: SentencePiece分词
description: 使用 BPE/Unigram 进行语言无关的文本分词（T5、ALBERT），适用于多语言或 CJK 语言支持场景。
version: 1.0.0
author: Orchestra Research
license: MIT
tags: [分词, SentencePiece, 语言无关, BPE, Unigram, 多语言, CJK语言, Unicode, 确定性, Google]
dependencies: [sentencepiece, transformers]
---

# SentencePiece - 语言无关分词

无监督分词器，无需特定语言的预处理即可直接处理原始文本。

## 适用场景与替代方案

**适合使用 SentencePiece 的场景：**
- 构建多语言模型（无特定语言规则）
- 处理 CJK 语言（中文、日文、韩文）
- 需要可复现的分词结果（确定性词表）
- 希望在原始文本上训练（无需预分词）
- 需要轻量级部署（6MB 内存，每秒处理 5 万句）

**性能指标**：
- **速度**：每秒 50,000 句
- **内存**：加载模型约 6MB
- **语言支持**：全语言（语言无关）

**建议改用替代方案的场景**：
- **HuggingFace Tokenizers**：训练更快、灵活性更高
- **tiktoken**：OpenAI 模型（GPT-3.5/4）
- **BERT WordPiece**：以英文为中心的任务

## 快速开始

### 安装

```bash
# Python
pip install sentencepiece

# C++（需要 CMake）
git clone https://github.com/google/sentencepiece.git
cd sentencepiece
mkdir build && cd build
cmake .. && make -j $(nproc)
sudo make install
```

### 训练模型

```bash
# 命令行（BPE，词表大小 8000）
spm_train --input=data.txt --model_prefix=m --vocab_size=8000 --model_type=bpe

# Python API
import sentencepiece as spm

spm.SentencePieceTrainer.train(
    input='data.txt',
    model_prefix='m',
    vocab_size=8000,
    model_type='bpe'
)
```

**训练时间**：100MB 语料约 1-2 分钟

### 编码与解码

```python
import sentencepiece as spm

# 加载模型
sp = spm.SentencePieceProcessor(model_file='m.model')

# 编码为分词片段
pieces = sp.encode('This is a test', out_type=str)
print(pieces)  # ['▁This', '▁is', '▁a', '▁test']

# 编码为 ID 序列
ids = sp.encode('This is a test', out_type=int)
print(ids)  # [284, 47, 11, 1243]

# 解码
text = sp.decode(ids)
print(text)  # "This is a test"
```

## 语言无关设计

### 空格符号化（▁）

```python
text = "Hello world"
pieces = sp.encode(text, out_type=str)
print(pieces)  # ['▁Hello', '▁world']

# 解码时保留空格
decoded = sp.decode_pieces(pieces)
print(decoded)  # "Hello world"
```

**核心原则**：将文本视为原始 Unicode，空格用 ▁（元符号）表示

## 分词算法

### BPE（字节对编码）

```python
spm.SentencePieceTrainer.train(
    input='data.txt',
    model_prefix='bpe_model',
    vocab_size=16000,
    model_type='bpe'
)
```

**使用该算法的模型**：mBART

### Unigram（默认）

```python
spm.SentencePieceTrainer.train(
    input='data.txt',
    model_prefix='unigram_model',
    vocab_size=8000,
    model_type='unigram'
)
```

**使用该算法的模型**：T5、ALBERT、XLNet

## 训练配置

### 核心参数

```python
spm.SentencePieceTrainer.train(
    input='corpus.txt',
    model_prefix='m',
    vocab_size=32000,
    model_type='unigram',
    character_coverage=0.9995,  # CJK 语言设为 1.0
    user_defined_symbols=['[SEP]', '[CLS]'],
    unk_piece='<unk>',
    num_threads=16
)
```

### 字符覆盖率

| 语言类型 | 覆盖率 | 说明 |
|---------------|----------|-----------|
| 英语 | 0.9995 | 覆盖最常见字符 |
| CJK（中文） | 1.0 | 需要覆盖所有字符 |
| 多语言 | 0.9995 | 取平衡值 |

## 编码选项

### 子词正则化

```python
# 采样不同的分词方式
for _ in range(3):
    pieces = sp.encode('tokenization', out_type=str, enable_sampling=True, alpha=0.1)
    print(pieces)

# 输出（每次不同）：
# ['▁token', 'ization']
# ['▁tok', 'en', 'ization']
```

**适用场景**：用于增强鲁棒性的数据增广。

## 常用模式

### T5 风格训练

```python
spm.SentencePieceTrainer.train(
    input='c4_corpus.txt',
    model_prefix='t5',
    vocab_size=32000,
    model_type='unigram',
    user_defined_symbols=[f'<extra_id_{i}>' for i in range(100)],
    unk_id=2,
    eos_id=1,
    pad_id=0
)
```

### 与 transformers 集成

```python
from transformers import T5Tokenizer

# T5 内部使用 SentencePiece
tokenizer = T5Tokenizer.from_pretrained('t5-base')
inputs = tokenizer('translate English to French: Hello', return_tensors='pt')
```

## 性能基准

### 训练速度

| 语料 | BPE（16k） | Unigram（8k） |
|--------|-----------|--------------|
| 100 MB | 1-2 分钟 | 3-4 分钟 |
| 1 GB | 10-15 分钟 | 30-40 分钟 |

### 分词速度

- **SentencePiece**：每秒 50,000 句
- **HF Tokenizers**：每秒 200,000 句（快 4 倍）

## 支持的模型

**T5 系列**：`t5-base`、`t5-large`（词表 32k，Unigram）
**ALBERT**：`albert-base-v2`（词表 30k，Unigram）
**XLNet**：`xlnet-base-cased`（词表 32k，Unigram）
**mBART**：`facebook/mbart-large-50`（词表 250k，BPE）

## 参考文档

- **[训练指南](references/training.md)** - 详细参数说明、语料准备
- **[算法说明](references/algorithms.md)** - BPE 与 Unigram 对比、子词正则化

## 参考资源

- **GitHub**：https://github.com/google/sentencepiece ⭐ 10,000+
- **论文**：https://arxiv.org/abs/1808.06226（EMNLP 2018）
- **版本**：0.2.0+



---
如未收到具体问题，直接询问："您在使用 SentencePiece 时想构建什么或调试什么问题？请分享您的代码、配置或报错信息。"
