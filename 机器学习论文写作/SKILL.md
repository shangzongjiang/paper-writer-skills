---
name: 机器学习论文写作
description: 面向 NeurIPS、ICML、ICLR、ACL 撰写机器学习论文，适用于从研究仓库起草或准备 camera-ready 投稿。
version: 1.2.0
author: Orchestra Research
license: MIT
tags: [学术写作, NeurIPS, ICML, ICLR, ACL, AAAI, COLM, LaTeX, 论文写作, 引用核实, 科研]
dependencies: [semanticscholar, arxiv, habanero, requests]
---

# 面向顶级 AI 会议的机器学习论文写作

为撰写投稿 **NeurIPS、ICML、ICLR、ACL、AAAI、COLM** 的发表级论文提供专家级指导。本技能融合了顶尖研究者的写作理念（Nanda、Farquhar、Karpathy、Lipton、Steinhardt）与实用工具：LaTeX 模板、引用核实 API 和会议检查清单。

**若要为时间序列预测论文构建段落级结构蓝图、查阅标准数据集/基线速查表或审稿痛点清单**，使用 [时间序列论文写作](../时间序列论文写作/) 技能，两者配合使用。

## 核心理念：协作式写作

**论文写作是协作过程，但 Claude 应当主动交付草稿，而非被动等待。**

典型工作流从一个包含代码、结果和实验产物的研究仓库开始。Claude 的角色是：

1. **理解项目** —— 探索仓库、结果与现有文档
2. **在有信心时交付完整初稿**
3. **检索文献** —— 用网络搜索和 API 查找相关引用
4. **根据反馈迭代优化**
5. **仅在关键决策确实不确定时才提问**

**核心原则**：保持主动。如果仓库和结果足够清晰，就直接交付完整草稿。不要为每个小节都等待反馈——科研人员很忙。先产出具体内容供其反应，再根据反馈迭代。

---

## ⚠️ 关键原则：绝不捏造引用

**这是借助 AI 进行学术写作时最重要的规则。**

### 问题所在
AI 生成的引用错误率约为 **40%**。幻觉引用——不存在的论文、错误的作者、错误的年份、虚构的 DOI——是严重的学术不端行为，可能导致直接拒稿或撤稿。

### 规则
**绝不凭记忆生成 BibTeX 条目。始终通过程序化方式获取。**

| 操作 | ✅ 正确 | ❌ 错误 |
|------|---------|---------|
| 添加引用 | 搜索 API → 核实 → 获取 BibTeX | 凭记忆写 BibTeX |
| 不确定某篇论文 | 标记为 `[CITATION NEEDED]` | 猜测引用信息 |
| 找不到精确匹配的论文 | 注明"占位符 - 待核实" | 编造听起来相似的论文 |

### 当无法核实某条引用时

如果无法通过程序化方式核实某条引用，必须：

```latex
% 明确的占位符 - 需要人工核实
\cite{PLACEHOLDER_author2024_verify_this}  % TODO：核实该引用是否真实存在
```

**务必告知科研人员**："我已将 [X] 条引用标记为待核实占位符。我无法确认这些论文是否存在。"

### 推荐：安装 Exa MCP 用于论文检索

为获得最佳的论文检索体验，建议安装 **Exa MCP**，它提供实时学术检索：

**Claude Code：**
```bash
claude mcp add exa -- npx -y mcp-remote "https://mcp.exa.ai/mcp"
```

**Cursor / VS Code**（添加到 MCP 设置）：
```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp"
    }
  }
}
```

Exa MCP 支持如下检索：
- "查找 2023 年后发表的关于语言模型 RLHF 的论文"
- "搜索 Vaswani 等人关于 Transformer 架构的论文"
- "获取近期关于稀疏自编码器可解释性的工作"

之后用 Semantic Scholar API 核实结果，并通过 DOI 获取 BibTeX。

---

## 工作流 0：从研究仓库起步

开始撰写论文时，先从理解项目开始：

```
项目理解清单：
- [ ] 步骤 1：探索仓库结构
- [ ] 步骤 2：阅读 README、现有文档与关键结果
- [ ] 步骤 3：与科研人员一起确定核心贡献
- [ ] 步骤 4：阅读 references/lab-style-guide.md —— 在起草任何章节前，内化实验室写作惯例（摘要结构、引言套路、模块命名、贡献列举格式）
- [ ] 步骤 5：查找代码库中已引用的论文
- [ ] 步骤 6：检索其他相关文献
- [ ] 步骤 7：共同梳理论文结构大纲
- [ ] 步骤 8：按反馈迭代起草各章节，保持实验室写作风格一致
```

**步骤 1：探索仓库**

```bash
# 了解项目结构
ls -la
find . -name "*.py" | head -20
find . -name "*.md" -o -name "*.txt" | xargs grep -l -i "result\|conclusion\|finding"
```

需要重点查看：
- `README.md` —— 项目概述与主张
- `results/`、`outputs/`、`experiments/` —— 关键发现
- `configs/` —— 实验设置
- 已有的 `.bib` 文件或引用记录
- 任何草稿文档或笔记

**步骤 2：识别已有引用**

检查代码库中已经引用过的论文：

```bash
# 查找已有引用
grep -r "arxiv\|doi\|cite" --include="*.md" --include="*.bib" --include="*.py"
find . -name "*.bib"
```

这些是撰写相关工作章节的高置信度起点——科研人员已经判断过它们的相关性。

**步骤 3：明确核心贡献**

写作前，明确与科研人员确认：

> "根据我对仓库的理解，本文的核心贡献似乎是 [X]。
> 关键结果显示 [Y]。这是你想要的论文叙事框架吗，
> 还是应该强调不同的方面？"

**绝不擅自假设论文叙事——务必与人类确认。**

**步骤 4：检索补充文献**

用网络搜索查找相关论文：

```
可尝试的检索词：
- "[核心技术] + [应用领域]"
- "[基线方法] comparison"
- "[问题名称] state-of-the-art"
- 已有引用中的作者姓名
```

之后用下方的引用工作流核实并获取 BibTeX。

**步骤 5：交付初稿**

**保持主动——直接交付完整草稿，而不是逐节请求许可。**

如果仓库提供了清晰的结果且贡献明显：
1. 端到端撰写完整初稿
2. 提交完整草稿供反馈
3. 根据科研人员的反应迭代

如果对论文框架或主要主张确实不确定：
1. 先起草有信心的部分
2. 明确标注具体的不确定点："我把 X 框定为核心贡献——如果你更想强调 Y，请告诉我"
3. 继续推进草稿，而不是停下来等待

**随草稿一起提出的问题**（而非提问后再写）：
- "我把 X 作为核心贡献——如有需要请调整"
- "我突出了结果 A、B、C——如果其他结果更重要请告诉我"
- "相关工作章节包含了 [论文列表]——补充我可能漏掉的"

---

## 何时使用本技能

适用场景：
- **从研究仓库起步**撰写论文
- **起草或修改**特定章节
- 为相关工作**查找并核实引用**
- 为会议投稿进行**格式化**
- **改投**其他会议（格式转换）
- 根据科研人员反馈**迭代**草稿

**始终牢记**：初稿是讨论的起点，不是最终产出。

---

## 主动性与协作的平衡

**默认：保持主动。先交付草稿，再迭代。**

| 置信水平 | 行动 |
|---------|------|
| **高**（仓库清晰、贡献明显） | 撰写完整草稿，交付，根据反馈迭代 |
| **中**（存在一定模糊性） | 撰写草稿并标注不确定点，继续推进 |
| **低**（存在重大未知项） | 提出 1-2 个针对性问题，再起草 |

**先起草，随草稿一起提问**（而非提问在前）：

| 章节 | 是否自主起草 | 随草稿标注的问题 |
|------|-------------|-----------------|
| 摘要 | 是 | "把贡献框定为 X——如需调整请说明" |
| 引言 | 是 | "强调了问题 Y——如有误请纠正" |
| 方法 | 是 | "包含了细节 A、B、C——补充缺漏部分" |
| 实验 | 是 | "突出了结果 1、2、3——如需重排请说明" |
| 相关工作 | 是 | "引用了论文 X、Y、Z——补充我漏掉的" |

**仅在以下情况才停下来等待输入：**
- 目标会议不明确（影响页数限制与论文框架）
- 多种相互矛盾的论文框架看起来同样合理
- 结果显得不完整或不一致
- 明确要求在继续前先审阅

**不要为以下情况停下来等待：**
- 措辞选择
- 章节顺序
- 展示哪些具体结果（自己做决定，标注出来即可）
- 引用完整性（用已找到的先写，标注空缺）

---

## 论题原则

**最关键的洞见**：你的论文不是一堆实验的堆砌——它是一个有单一明确贡献、并有证据支撑的故事。

每一篇成功的 ML 论文都围绕 Neel Nanda 所说的"论题"（the narrative）展开：一个简短、严谨、基于证据、读者会在意其结论的技术故事。

**三大支柱**（引言结束时必须清晰呈现）：

| 支柱 | 描述 | 示例 |
|------|------|------|
| **是什么** | 1-3 项有内在统一主题的具体新主张 | "我们证明 X 在条件 Z 下能达到 Y" |
| **为什么** | 支撑主张的严谨实证证据 | 强基线、能区分不同假设的实验 |
| **所以呢** | 为何读者应该关心 | 与社区公认问题的关联 |

**如果你无法用一句话陈述你的贡献，说明你还没有真正想清楚这篇论文。**

---

## 论文结构工作流

### 工作流 1：撰写完整论文（迭代式）

复制以下清单并跟踪进度。**每一步都是"起草 → 反馈 → 修订"的循环：**

```
论文写作进度：
- [ ] 步骤 1：（与科研人员一起）确定一句话贡献
- [ ] 步骤 2：起草 Figure 1 → 获取反馈 → 修订
- [ ] 步骤 3：起草摘要 → 获取反馈 → 修订
- [ ] 步骤 4：起草引言 → 获取反馈 → 修订
- [ ] 步骤 5：起草方法 → 获取反馈 → 修订
- [ ] 步骤 6：起草实验 → 获取反馈 → 修订
- [ ] 步骤 7：起草相关工作 → 获取反馈 → 修订
- [ ] 步骤 8：起草局限性 → 获取反馈 → 修订
- [ ] 步骤 9：完成论文检查清单（必需）
- [ ] 步骤 10：终审与投稿
```

**步骤 1：确定一句话贡献**

**此步骤需要科研人员明确确认。**

写作前，先阐明并核实：
- 这篇论文唯一的核心贡献是什么？
- 在你的工作之前，什么是不明显或不存在的？

> "我建议把贡献框定为：'[一句话]'。这是否抓住了
> 你认为的核心结论？是否需要调整侧重点？"

**步骤 2：起草 Figure 1**

Figure 1 值得特别关注——很多读者会直接跳到这里看。
- 传达核心思想、方法或最有说服力的结果
- 使用矢量图（图表用 PDF/EPS）
- 图注应能脱离正文独立理解
- 确保黑白打印下仍可读（8% 的男性存在色觉缺陷）

**步骤 3：撰写摘要（五句话公式）**

源自 Sebastian Farquhar（DeepMind）：

```
第 1 句：你做出了什么——"We introduce..."、"We prove..."、"We demonstrate..."
第 2 句：为何这件事困难且重要
第 3 句：你是怎么做的（用领域关键词以便被检索到）
第 4 句：你有什么证据
第 5 句：你最亮眼的数字/结果
```

**删除**类似"大语言模型已取得显著成功……"这种可以套用到任何 ML 论文开头的泛泛之言。

**步骤 4：撰写引言（最多 1-1.5 页）**

必须包含：
- 2-4 条贡献列表（双栏格式下每条最多 1-2 行）
- 清晰的问题陈述
- 简要的方法概述
- 方法章节最晚应从第 2-3 页开始

**步骤 5：方法章节**

确保可复现：
- 概念性大纲或伪代码
- 列出所有超参数
- 提供足以复现的架构细节
- 呈现最终设计决策；消融实验放在实验章节

**步骤 6：实验章节**

每个实验都要明确说明：
- 它支撑什么主张
- 它与核心贡献的关联
- 实验设置（细节放附录）
- 应该观察到什么："蓝线显示 X，这说明了 Y"

要求：
- 误差条并说明方法（标准差还是标准误）
- 超参数搜索范围
- 计算资源（GPU 型号、总耗时）
- 随机种子设置方法

**步骤 7：相关工作**

按方法论而非逐篇罗列组织：

**好的写法：**"一类工作采用 Floogledoodle 的假设 [refs]，而我们采用 Doobersnoddle 的假设，因为……"

**不好的写法：**"Snap 等人提出了 X，而 Crackle 等人提出了 Y。"

引用要慷慨——审稿人很可能就是相关论文的作者。

**步骤 8：局限性章节（必需）**

所有主要会议都要求此章节。反直觉的是，诚实反而有帮助：
- 审稿人被要求不能因诚实承认局限而扣分
- 主动指出弱点可以先发制人地化解批评
- 解释为何这些局限不影响核心主张

**步骤 9：论文检查清单**

NeurIPS、ICML、ICLR 均要求论文检查清单。参见 [references/checklists.md](references/checklists.md)。

---

## 顶级 ML 会议的写作理念

**本节提炼了顶尖 ML 研究者最重要的写作原则。** 这些不是可选的风格建议——它们是录用论文与拒稿论文之间的真正分界线。

> "论文是一个简短、严谨、基于证据的技术故事，有一个读者会在意的结论。" —— Neel Nanda

### 本指导的来源

本技能综合了在顶级会议上发表过大量论文的研究者的写作理念：

| 来源 | 核心贡献 | 链接 |
|------|----------|------|
| **Neel Nanda**（Google DeepMind） | 论题原则、"是什么/为什么/所以呢"框架 | [How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers) |
| **Sebastian Farquhar**（DeepMind） | 五句话摘要公式 | [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/) |
| **Gopen & Swan** | 读者预期七原则 | [Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf) |
| **Zachary Lipton** | 措辞选择、消除模糊限定语 | [Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/) |
| **Jacob Steinhardt**（UC Berkeley） | 精确性、术语一致性 | [Writing Tips](https://bounded-regret.ghost.io/) |
| **Ethan Perez**（Anthropic） | 微观层面的清晰度技巧 | [Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/) |
| **Andrej Karpathy** | 单一贡献聚焦 | 多场讲座 |

**深入了解以上任意一项，参见：**
- [references/writing-guide.md](references/writing-guide.md) —— 含示例的完整说明
- [references/sources.md](references/sources.md) —— 完整参考文献列表

### 时间分配（源自 Neel Nanda）

在以下四项上**大致平均分配**时间：
1. 摘要
2. 引言
3. 图表
4. 其余所有内容合计

**为什么？** 大多数审稿人在读到方法章节之前就已经形成判断。读者接触论文的顺序是：**标题 → 摘要 → 引言 → 图表 → 也许才是其余部分。**

### 写作风格准则

#### 句子层面的清晰度（Gopen & Swan 的七原则）

这些原则基于读者实际处理文字的方式。违反它们会迫使读者把认知资源花在理解句子结构上，而不是内容本身。

| 原则 | 规则 | 示例 |
|------|------|------|
| **主谓靠近** | 主语和动词保持靠近 | ❌ "The model, which was trained on..., achieves" → ✅ "The model achieves... after training on..." |
| **强调位置** | 把重点放在句尾 | ❌ "Accuracy improves by 15% when using attention" → ✅ "When using attention, accuracy improves by **15%**" |
| **主题位置** | 先给上下文，再给新信息 | ✅ "Given these constraints, we propose..." |
| **旧信息先于新信息** | 熟悉的信息 → 不熟悉的信息 | 先承接上文，再引入新内容 |
| **一个单元一个功能** | 每段只表达一个观点 | 拆分包含多个观点的段落 |
| **动作放进动词** | 用动词而非名词化表达 | ❌ "We performed an analysis" → ✅ "We analyzed" |
| **先给情境再给新内容** | 先铺垫，再呈现 | 先解释，再给出公式 |

**完整七原则及详细示例：**参见 [references/writing-guide.md](references/writing-guide.md#the-7-principles-of-reader-expectations)

#### 微观层面的技巧（Ethan Perez）

这些细小的改动累积起来会让文字显著更清晰：

- **少用代词**：❌ "This shows..." → ✅ "This result shows..."
- **动词提前**：把动词放在靠近句首的位置
- **展开所有格**：❌ "X's Y" → ✅ "The Y of X"（在生硬时使用）
- **删除填充词**："actually"、"a bit"、"very"、"really"、"basically"、"quite"、"essentially"

**完整微观技巧及示例：**参见 [references/writing-guide.md](references/writing-guide.md#micro-level-writing-tips)

#### 措辞选择（Zachary Lipton）

- **要具体**：❌ "performance" → ✅ "accuracy" 或 "latency"（说清楚你指的是什么）
- **消除模糊限定语**：除非真的不确定，否则去掉 "may" 和 "can"
- **避免增量式词汇**：❌ "combine"、"modify"、"expand" → ✅ "develop"、"propose"、"introduce"
- **删除强调词**：❌ "provides *very* tight approximation" → ✅ "provides tight approximation"

#### 精确优先于简洁（Jacob Steinhardt）

- **术语一致**：同一概念用不同词表达会造成混乱。选定一个术语并坚持使用。
- **正式陈述假设**：在定理之前明确列出所有假设
- **直觉 + 严谨**：在给出形式化证明的同时提供直觉性解释

### 审稿人实际会读什么

理解审稿人的阅读行为有助于合理分配精力：

| 论文章节 | 阅读该章节的审稿人比例 | 启示 |
|---------|----------------------|------|
| 摘要 | 100% | 必须做到完美 |
| 引言 | 90%+（略读） | 把贡献前置 |
| 图表 | 在读方法之前就会先看 | Figure 1 至关重要 |
| 方法 | 只有感兴趣时才读 | 不要把重点埋藏其中 |
| 附录 | 很少读 | 只放补充性细节 |

**结论**：如果你的摘要和引言无法吸引审稿人，他们可能永远不会读到你出色的方法章节。

---

## 会议要求快速参考

### ML/AI 会议

| 会议 | 页数限制 | Camera-Ready 额外页数 | 关键要求 |
|------|----------|------------------------|----------|
| **NeurIPS 2025** | 9 页 | +0 | 强制检查清单，录用后需提供大众化摘要 |
| **ICML 2026** | 8 页 | +1 | 必须包含 Broader Impact Statement |
| **ICLR 2026** | 9 页 | +1 | 需披露 LLM 使用情况，互惠评审 |
| **ACL 2025** | 8 页（长文） | 视情况而定 | 必须包含 Limitations 章节 |
| **AAAI 2026** | 7 页 | +1 | 严格遵循样式文件 |
| **COLM 2025** | 9 页 | +1 | 聚焦语言模型 |

**通用要求：**
- 双盲评审（投稿需匿名化）
- 参考文献不计入页数限制
- 附录页数不限，但审稿人不要求阅读
- 所有会议均要求使用 LaTeX

**LaTeX 模板：**参见 [templates/](templates/) 目录中的各会议模板。

---

## 正确使用 LaTeX 模板

### 工作流 4：从模板开始一篇新论文

**始终先复制整个模板目录，再在其中写作。**

```
模板设置清单：
- [ ] 步骤 1：将整个模板目录复制到新项目
- [ ] 步骤 2：在做任何修改前，先验证模板能正常编译
- [ ] 步骤 3：阅读模板的示例内容，理解其结构
- [ ] 步骤 4：逐节替换示例内容
- [ ] 步骤 5：在完成前保留模板注释/示例作为参考
- [ ] 步骤 6：仅在最后才清理模板残留内容
```

**步骤 1：复制完整模板**

```bash
# 用完整模板创建你的论文目录
cp -r templates/neurips2025/ ~/papers/my-new-paper/
cd ~/papers/my-new-paper/

# 确认结构完整
ls -la
# 应该能看到：main.tex、neurips.sty、Makefile 等
```

**⚠️ 重要**：要复制整个目录，而不是只复制 `main.tex`。模板包含：
- 样式文件（`.sty`）—— 编译必需
- 参考文献样式（`.bst`）—— 引用格式必需
- 示例内容 —— 可作为参考
- Makefile —— 方便编译

**步骤 2：先验证模板本身能否编译**

在做任何修改之前，先编译未经修改的模板：

```bash
# 使用 latexmk（推荐）
latexmk -pdf main.tex

# 或手动编译
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

如果未修改的模板都无法编译，先解决这个问题。常见原因：
- 缺少 TeX 包 → 通过 `tlmgr install <package>` 安装
- TeX 发行版不对 → 推荐使用 TeX Live

**步骤 3：保留模板内容作为参考**

不要立刻删除所有示例内容，而是：

```latex
% 写作时把模板示例注释掉保留
% 这样可以随时查看期望的格式

% 模板示例（保留作参考）：
% \begin{figure}[t]
%   \centering
%   \includegraphics[width=0.8\linewidth]{example-image}
%   \caption{Template shows caption style}
% \end{figure}

% 你的实际图表：
\begin{figure}[t]
  \centering
  \includegraphics[width=0.8\linewidth]{your-figure.pdf}
  \caption{Your caption following the same style.}
\end{figure}
```

**步骤 4：逐节替换内容**

按顺序系统地处理整篇论文：

```
替换顺序：
1. 标题与作者（投稿时匿名化）
2. 摘要
3. 引言
4. 方法
5. 实验
6. 相关工作
7. 结论
8. 参考文献（你的 .bib 文件）
9. 附录
```

对每一节：
1. 阅读模板的示例内容
2. 注意其中使用的特殊格式或宏
3. 按相同模式替换为你的内容
4. 频繁编译，及早发现错误

**步骤 5：使用模板宏**

模板通常定义了一些实用宏。检查文档头部（preamble）：

```latex
% 常见的模板宏：
\newcommand{\method}{YourMethodName}  % 统一的方法名称
\newcommand{\eg}{e.g.,\xspace}        % 规范的缩写
\newcommand{\ie}{i.e.,\xspace}
\newcommand{\etal}{\textit{et al.}\xspace}
```

**步骤 6：只在最后清理**

只有当论文接近完成时才移除模板残留：

```latex
% 投稿前 - 移除以下内容：
% - 注释掉的模板示例
% - 未使用的包
% - 模板自带的示例图表
% - Lorem ipsum 或占位文本

% 保留以下内容：
% - 所有样式文件（.sty）
% - 参考文献样式（.bst）
% - 模板要求的必需包
% - 你正在使用的自定义宏
```

### 应避免的模板陷阱

| 陷阱 | 问题 | 解决方法 |
|------|------|----------|
| 只复制 `main.tex` | 缺少 `.sty`，无法编译 | 复制整个目录 |
| 修改 `.sty` 文件 | 破坏会议规定的格式 | 绝不编辑样式文件 |
| 随意添加包 | 引发冲突，破坏模板 | 只在确有必要时添加 |
| 过早删除模板内容 | 丢失格式参考 | 完成前先注释保留 |
| 不频繁编译 | 错误会持续累积 | 每写完一节就编译一次 |

### 模板快速参考

#### ML/AI 会议

| 会议 | 主文件 | 关键样式文件 | 备注 |
|------|--------|--------------|------|
| NeurIPS 2025 | `main.tex` | `neurips.sty` | 含 Makefile |
| ICML 2026 | `example_paper.tex` | `icml2026.sty` | 含算法包 |
| ICLR 2026 | `iclr2026_conference.tex` | `iclr2026_conference.sty` | 含 math_commands.tex |
| ACL | `acl_latex.tex` | `acl.sty` | 格式要求严格 |
| AAAI 2026 | `aaai2026-unified-template.tex` | `aaai2026.sty` | 合规要求非常严格 |
| COLM 2025 | `colm2025_conference.tex` | `colm2025_conference.sty` | 与 ICLR 类似 |

---

## 改投会议与格式转换

当论文被某会议拒稿或撤回后改投其他会议，需要进行格式转换。这是 ML 研究中常见的工作流。

### 工作流 3：在不同会议格式之间转换

```
格式转换清单：
- [ ] 步骤 1：识别源模板与目标模板的差异
- [ ] 步骤 2：用目标模板创建新项目
- [ ] 步骤 3：复制内容章节（而非文档头部）
- [ ] 步骤 4：调整页数与内容
- [ ] 步骤 5：更新会议特定要求
- [ ] 步骤 6：验证编译与格式
```

**步骤 1：关键模板差异**

#### ML/AI 会议间转换

| 从 → 到 | 页数变化 | 关键调整 |
|---------|----------|----------|
| NeurIPS → ICML | 9 → 8 页 | 删减 1 页，若缺失需补充 Broader Impact |
| ICML → ICLR | 8 → 9 页 | 可扩展实验，补充 LLM 披露 |
| NeurIPS → ACL | 9 → 8 页 | 按 NLP 惯例重新组织结构，补充 Limitations |
| ICLR → AAAI | 9 → 7 页 | 需大幅删减，严格遵循样式规范 |
| 任意 → COLM | 视情况 → 9 页 | 围绕语言模型重新框定论文 |

**步骤 2：内容迁移（而非合并模板）**

**绝不要在不同模板之间复制 LaTeX 文档头部。** 而应该：

```bash
# 1. 用目标模板从零开始
cp -r templates/icml2026/ new_submission/

# 2. 只从旧论文中复制内容章节
# - 摘要文本
# - 各 \section{} 之间的正文内容
# - 图表
# - 参考文献条目

# 3. 粘贴进目标模板结构中
```

**步骤 3：调整页数限制**

删减页数时（例如 NeurIPS 9 页 → AAAI 7 页）：
- 把详细证明移到附录
- 精简相关工作（引用综述而非逐篇引用）
- 把相似实验合并为统一表格
- 用更小的图配合子图
- 精炼文字：消除冗余，使用主动语态

扩充页数时（例如 ICML 8 页 → ICLR 9 页）：
- 补充审稿人要求的消融实验
- 扩展局限性讨论
- 增加额外基线
- 补充定性示例

**步骤 4：会议特定调整**

#### ML/AI 会议

| 目标会议 | 必需的额外内容 |
|----------|----------------|
| **ICML** | Broader Impact Statement（放在结论之后） |
| **ICLR** | LLM 使用披露、互惠评审协议 |
| **ACL/EMNLP** | Limitations 章节（必需）、Ethics Statement |
| **AAAI** | 严格遵循样式文件（不得修改） |
| **NeurIPS** | 论文检查清单（附录）、录用后需提供大众化摘要 |

**步骤 5：更新参考文献**

```latex
% 移除会暴露身份的自引用（用于双盲评审）
% 把"投稿中"的引用更新为已发表版本
% 补充上次投稿后新发表的相关工作
```

**步骤 6：回应既往审稿意见**

改投被拒论文时：
- **应该**在新版本中回应审稿人的关切
- **应该**补充审稿人要求的实验/澄清
- **不应该**包含"与上次投稿相比的改动"章节（双盲评审）
- **不应该**提及上次投稿或评审意见

**常见的转换陷阱：**
- ❌ 直接复制 `\usepackage` 命令（引发冲突）
- ❌ 保留旧会议的页眉/页脚命令
- ❌ 忘记更新 `\bibliography{}` 路径
- ❌ 缺少目标会议特定的必需章节
- ❌ 格式转换后超出页数限制

---

## 引用工作流（防止幻觉引用）

**⚠️ 关键**：AI 生成的引用错误率约 40%。**绝不凭记忆撰写 BibTeX。**

### 黄金法则

```
如果你无法通过程序化方式获取某条引用：
    → 标记为 [CITATION NEEDED] 或 [PLACEHOLDER - VERIFY]
    → 明确告知科研人员
    → 绝不编造一条听起来合理的引用
```

### 工作流 2：添加引用

```
引用核实流程（每条引用都必须执行）：
- [ ] 步骤 1：用 Exa MCP 或 Semantic Scholar API 检索
- [ ] 步骤 2：在 2 个以上来源中核实论文存在（Semantic Scholar + arXiv/CrossRef）
- [ ] 步骤 3：通过 DOI 程序化获取 BibTeX（而非凭记忆）
- [ ] 步骤 4：核实你所引用的主张确实出现在该论文中
- [ ] 步骤 5：将核实过的 BibTeX 加入参考文献
- [ ] 步骤 6：任一步骤失败 → 标记为占位符，告知科研人员
```

**步骤 0：用 Exa MCP 进行初步检索（推荐）**

如果已安装 Exa MCP，用它检索相关论文：
```
检索词："RLHF language model alignment 2023"
检索词："sparse autoencoders interpretability"
检索词："attention mechanism transformers Vaswani"
```

之后用 Semantic Scholar 核实每个结果，并通过 DOI 获取 BibTeX。

**步骤 1：检索 Semantic Scholar**

```python
from semanticscholar import SemanticScholar

sch = SemanticScholar()
results = sch.search_paper("attention mechanism transformers", limit=5)
for paper in results:
    print(f"{paper.title} - {paper.paperId}")
    print(f"  DOI: {paper.externalIds.get('DOI', 'N/A')}")
```

**步骤 2：核实论文存在**

确认该论文至少在两个来源中出现（Semantic Scholar + CrossRef/arXiv）。

**步骤 3：通过 DOI 获取 BibTeX**

```python
import requests

def doi_to_bibtex(doi: str) -> str:
    """通过 CrossRef，依据 DOI 获取经核实的 BibTeX。"""
    response = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex"}
    )
    response.raise_for_status()
    return response.text

# 示例
bibtex = doi_to_bibtex("10.48550/arXiv.1706.03762")
print(bibtex)
```

**步骤 4：核实具体主张**

在为某个具体主张引用之前，访问该论文并确认所归因的主张确实出现在其中。

**步骤 5：明确处理失败情况**

如果在任何步骤都无法核实某条引用：

```latex
% 方案 1：明确的占位符
\cite{PLACEHOLDER_smith2023_verify}  % TODO：未能核实 - 需科研人员确认

% 方案 2：正文中标注
... as shown in prior work [CITATION NEEDED - 未能核实 Smith et al. 2023]。
```

**务必告知科研人员：**
> "以下引用我未能核实，已标记为占位符：
> - Smith et al. 2023 关于 reward hacking —— 在 Semantic Scholar 中找不到
> - Jones 2022 关于 scaling laws —— 找到了类似论文但作者不同
> 请在投稿前核实这些引用。"

### 引用规则总结

| 情况 | 处理方式 |
|------|----------|
| 找到论文、获取了 DOI、拿到了 BibTeX | ✅ 使用该引用 |
| 找到论文，但没有 DOI | ✅ 使用 arXiv 的 BibTeX 或根据论文手动录入 |
| 论文确实存在但无法获取 BibTeX | ⚠️ 标记占位符，告知科研人员 |
| 不确定论文是否存在 | ❌ 标记 `[CITATION NEEDED]`，告知科研人员 |
| "我记得好像有篇关于 X 的论文" | ❌ **绝不引用** —— 先检索，否则标记占位符 |

**🚨 绝不凭记忆生成 BibTeX——始终通过程序化方式获取。🚨**

完整 API 文档参见 [references/citation-workflow.md](references/citation-workflow.md)。

---

## 常见问题与解决方案

**问题：摘要过于泛泛**

如果第一句可以套用到任何 ML 论文开头，就删掉它。从你的具体贡献开始写。

**问题：引言超过 1.5 页**

把背景知识拆分到相关工作章节。把贡献列表前置。方法章节最晚从第 2-3 页开始。

**问题：实验缺乏明确的主张**

在每个实验前加一句话："本实验验证 [具体主张] 是否成立……"

**问题：审稿人反馈论文难以理解**

- 加入明确的路标句："本节我们展示 X"
- 全文使用一致的术语
- 图注应能脱离正文独立理解

**问题：缺少统计显著性说明**

务必包含：
- 误差条（并说明是标准差还是标准误）
- 实验运行次数
- 比较不同方法时的统计检验

---

## 审稿评估标准

审稿人从四个维度评估论文：

| 标准 | 审稿人关注点 |
|------|-------------|
| **质量（Quality）** | 技术严谨性，主张有充分支撑 |
| **清晰度（Clarity）** | 写作清晰，专家可复现 |
| **重要性（Significance）** | 对社区的影响力，推动理解 |
| **原创性（Originality）** | 新的洞见（不要求一定是新方法） |

**评分标准（NeurIPS 6 分制）：**
- 6：强烈接受 —— 突破性，几近完美
- 5：接受 —— 技术扎实，影响力高
- 4：边缘接受 —— 扎实，但评估有限
- 3：边缘拒绝 —— 扎实但弱点大于优点
- 2：拒绝 —— 存在技术缺陷
- 1：强烈拒绝 —— 已有结论的重复或存在伦理问题

详细审稿说明参见 [references/reviewer-guidelines.md](references/reviewer-guidelines.md)。

---

## 表格与图表

### 表格

使用 `booktabs` LaTeX 包制作专业表格：

```latex
\usepackage{booktabs}
\begin{tabular}{lcc}
\toprule
Method & Accuracy ↑ & Latency ↓ \\
\midrule
Baseline & 85.2 & 45ms \\
\textbf{Ours} & \textbf{92.1} & 38ms \\
\bottomrule
\end{tabular}
```

**规则：**
- 每个指标列加粗最优值
- 标注方向符号（↑ 越高越好，↓ 越低越好）
- 数值列右对齐
- 小数位数保持一致

### 图表

- 所有图表使用**矢量图**（PDF、EPS）
- 仅照片使用**栅格图**（PNG 600 DPI）
- 使用**色盲友好配色**（Okabe-Ito 或 Paul Tol）
- 核实**灰度打印下的可读性**（8% 的男性存在色觉缺陷）
- **图内不放标题**——图注承担这一功能
- **图注自洽**——读者不看正文也应能理解

---

## 引用本研究技能库

如果本技能库对你的研究有所帮助——无论是训练流程、评估、论文写作还是其他任何环节——欢迎在致谢或参考文献中引用：

```bibtex
@software{ai_research_skills,
  title     = {AI Research Skills Library},
  author    = {{Orchestra Research}},
  year      = {2025},
  url       = {https://github.com/orchestra-research/AI-research-SKILLs},
  note      = {Open-source skills library enabling AI agents to autonomously conduct AI research}
}
```

在**致谢**章节中简单提及也是欢迎的：

```latex
\section*{Acknowledgments}
We used the AI Research Skills Library~\cite{ai_research_skills} for [experiment orchestration / evaluation / ...].
```

---

## 参考资料

### 参考文档（深入阅读）

| 文档 | 内容 |
|------|------|
| [writing-guide.md](references/writing-guide.md) | Gopen & Swan 七原则、Ethan Perez 微观技巧、措辞选择 |
| [citation-workflow.md](references/citation-workflow.md) | 引用 API、Python 代码、BibTeX 管理 |
| [checklists.md](references/checklists.md) | NeurIPS 16 项、ICML、ICLR、ACL 各自要求 |
| [reviewer-guidelines.md](references/reviewer-guidelines.md) | 评估标准、评分、答辩 |
| [sources.md](references/sources.md) | 所有来源的完整参考文献列表 |
| [lab-style-guide.md](references/lab-style-guide.md) | 实验室写作风格指南（基于 TimePMG、TimeMRA、MSH-LLM 提炼），含摘要结构、引言套路、方法描述规范、贡献列举格式、高频词汇表 |

### LaTeX 模板

`templates/` 目录下的模板：
- ICML 2026、ICLR 2026、NeurIPS 2025、ACL/EMNLP、AAAI 2026、COLM 2025

**编译为 PDF：**
- **VS Code/Cursor**：安装 LaTeX Workshop 插件 + TeX Live → 保存即自动编译
- **命令行**：`latexmk -pdf main.tex` 或 `pdflatex` + `bibtex` 工作流
- **在线**：上传到 [Overleaf](https://overleaf.com)

详细配置说明参见 [templates/README.md](templates/README.md)。

### 关键外部来源

**写作理念：**
- [Neel Nanda: How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers) —— 论题原则、"是什么/为什么/所以呢"
- [Farquhar: How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/) —— 五句话摘要
- [Gopen & Swan: Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf) —— 读者预期七原则
- [Lipton: Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/) —— 措辞选择
- [Perez: Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/) —— 微观层面的清晰度

**API：** [Semantic Scholar](https://api.semanticscholar.org/api-docs/) | [CrossRef](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) | [arXiv](https://info.arxiv.org/help/api/basics.html)

**ML/AI 会议官方说明：** [NeurIPS](https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles) | [ICML](https://icml.cc/Conferences/2025/AuthorInstructions) | [ICLR](https://iclr.cc/Conferences/2026/AuthorGuide) | [ACL](https://github.com/acl-org/acl-style-files)

---
如未收到具体问题，直接询问："你在机器学习论文写作方面想构建什么或调试什么？请分享你的代码、配置或错误信息。"
