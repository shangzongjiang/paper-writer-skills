# 分词算法

BPE 与 Unigram 的对比及子词正则化。

## BPE（字节对编码）

### 算法

1. 用字符初始化词表
2. 统计相邻 token 对的频率
3. 合并频率最高的 token 对
4. 重复上述过程，直到达到目标词表大小

### 示例

**语料库**：
```
low: 5
lower: 2
newest: 6
widest: 3
```

**第一轮迭代**：
- 频率最高的 token 对：'e' + 's'（共 9 次）
- 合并 → 'es'
- 词表：[字符] + ['es']

**第二轮迭代**：
- 频率最高的 token 对：'es' + 't'（共 9 次）
- 合并 → 'est'
- 词表：[字符] + ['es', 'est']

**结果**：`newest` → `new|est`，`widest` → `wid|est`

### 实现

```python
import sentencepiece as spm

spm.SentencePieceTrainer.train(
    input='corpus.txt',
    model_type='bpe',
    vocab_size=16000
)
```

### 优势

- 算法简单
- 训练速度快
- 压缩率高

### 劣势

- 确定性（不支持采样）
- 可能对常见词产生意外切分

## Unigram

### 算法

1. 从大词表开始（包含所有子字符串）
2. 计算每个 token 的概率
3. 移除损失影响最小的 token
4. 重复上述过程，直到达到目标词表大小

### 概率分词

给定带概率的词表：
```
P('low') = 0.02
P('est') = 0.03
P('l') = 0.01
P('o') = 0.015
...
```

对"lowest"进行分词：
```
Option 1: ['low', 'est']
P = 0.02 × 0.03 = 0.0006  ← highest

Option 2: ['l', 'o', 'w', 'est']
P = 0.01 × 0.015 × 0.01 × 0.03 = 0.000000045

Choose option 1 (highest probability)
```

### 实现

```python
spm.SentencePieceTrainer.train(
    input='corpus.txt',
    model_type='unigram',
    vocab_size=8000
)
```

### 优势

- 概率性（支持采样）
- 更适合形态丰富的语言
- 支持子词正则化

### 劣势

- 训练速度较慢
- 算法更复杂

## 对比

| 特性 | BPE | Unigram |
|---------|-----|---------|
| 训练速度 | 快 | 慢 |
| 分词方式 | 确定性 | 概率性 |
| 采样 | 不支持 | 支持 |
| 典型词表大小 | 16k-32k | 8k-32k |
| 使用模型 | mBART | T5、ALBERT、XLNet |

## 子词正则化

在训练过程中对不同分词结果进行采样，以提升鲁棒性。

### 启用采样

```python
sp = spm.SentencePieceProcessor(model_file='m.model')

# Sample different tokenizations
for _ in range(5):
    pieces = sp.encode('tokenization', out_type=str, enable_sampling=True, alpha=0.1)
    print(pieces)

# Output (different each time):
# ['▁token', 'ization']
# ['▁tok', 'en', 'ization']
# ['▁token', 'iz', 'ation']
# ['▁to', 'ken', 'ization']
# ['▁token', 'ization']
```

### 参数说明

- `alpha`：正则化强度
  - 0.0 = 确定性（不采样）
  - 0.1 = 轻微变化
  - 0.5 = 较大变化
  - 1.0 = 最大变化

### 优点

1. **鲁棒性**：模型可学习多种分词方式
2. **数据增强**：训练数据更多样化
3. **更好的泛化能力**：减少对特定分词方式的过拟合

### 使用示例

```python
# Training loop with regularization
for batch in dataloader:
    # Sample different tokenizations each epoch
    tokens = sp.encode(batch['text'], enable_sampling=True, alpha=0.1)
    # Train model...
```

**使用该方式的模型**：mT5、XLM-RoBERTa

## NBest 编码

获取多个带分数的分词候选结果。

```python
sp = spm.SentencePieceProcessor(model_file='m.model')

# Get top-5 tokenizations
nbest = sp.nbest_encode('tokenization', nbest_size=5, out_type=str)

for pieces, score in nbest:
    print(f"{pieces} (log prob: {score:.4f})")

# Output:
# ['▁token', 'ization'] (log prob: -2.34)
# ['▁tok', 'en', 'ization'] (log prob: -2.41)
# ['▁token', 'iz', 'ation'] (log prob: -2.57)
```

### 使用场景

1. **集成分词**：对多种分词结果取平均
2. **不确定性估计**：检查分数的方差
3. **调试**：理解分词器的行为

## 最佳实践

1. **多语言任务使用 Unigram** - 更适合多样化语言
2. **追求速度使用 BPE** - 训练和推理均更快
3. **启用子词正则化** - 提升模型鲁棒性
4. **将 alpha 设为 0.1 以获得轻微变化** - 兼顾效果与稳定性
5. **推理时使用确定性模式** - 保证结果一致性
