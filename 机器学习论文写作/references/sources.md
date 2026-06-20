# 参考文献目录

本文档列出了构建此技能所使用的所有权威来源，按主题分类整理。

---

## 写作理念与指南

### 核心来源（必读）

| 来源 | 作者 | URL | 核心贡献 |
|--------|--------|-----|------------------|
| **关于如何撰写 ML 论文的强烈意见建议** | Neel Nanda | [Alignment Forum](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers) | 叙事框架、"是什么/为什么/意义何在"、时间分配 |
| **如何撰写 ML 论文** | Sebastian Farquhar（DeepMind） | [博客](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/) | 五句摘要公式、结构模板 |
| **PhD 生存指南** | Andrej Karpathy | [博客](http://karpathy.github.io/2016/09/07/phd/) | 论文结构方法、贡献框架 |
| **科学写作启发式方法** | Zachary Lipton（CMU） | [博客](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/) | 词语选择、章节平衡、强调词警告 |
| **作者建议** | Jacob Steinhardt（UC Berkeley） | [博客](https://jsteinhardt.stat.berkeley.edu/blog/advice-for-authors) | 精确优于简洁、术语一致性 |
| **简易论文写作技巧** | Ethan Perez（Anthropic） | [博客](https://ethanperez.net/easy-paper-writing-tips/) | 微观层面技巧、撇号展开、清晰度技巧 |

### 基础科学写作

| 来源 | 作者 | URL | 核心贡献 |
|--------|--------|-----|------------------|
| **科学写作的科学** | Gopen & Swan | [PDF](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf) | 主题位置/强调位置、先旧后新、7 条原则 |
| **科学写作的科学摘要** | Lawrence Crowl | [摘要](https://www.crowl.org/Lawrence/writing/GopenSwan90.html) | Gopen & Swan 的精简版 |

### 其他参考资源

| 来源 | URL | 核心贡献 |
|--------|-----|------------------|
| ML 研究论文撰写指南 | [博客](https://grigorisg9gr.github.io/machine%20learning/research%20paper/how-to-write-a-research-paper-in-machine-learning/) | 实践演练、LaTeX 技巧 |
| 训练神经网络的方法 | [Karpathy 博客](http://karpathy.github.io/2019/04/25/recipe/) | 可转化为论文结构的调试方法论 |
| ICML 论文写作最佳实践 | [ICML](https://icml.cc/Conferences/2022/BestPractices) | 官方会议指导 |
| Bill Freeman 写作幻灯片 | [MIT](https://billf.mit.edu/sites/default/files/documents/cvprPapers.pdf) | 论文结构可视化指南 |

---

## 官方会议指南

### NeurIPS

| 文档 | URL | 用途 |
|----------|-----|---------|
| 论文清单指南 | [NeurIPS](https://neurips.cc/public/guides/PaperChecklist) | 16 项强制清单 |
| 审稿人指南 2025 | [NeurIPS](https://neurips.cc/Conferences/2025/ReviewerGuidelines) | 评估标准、评分 |
| 样式文件 | [NeurIPS](https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles) | LaTeX 模板 |

### ICML

| 文档 | URL | 用途 |
|----------|-----|---------|
| 论文指南 | [ICML](https://icml.cc/Conferences/2024/PaperGuidelines) | 投稿要求 |
| 审稿人说明 2025 | [ICML](https://icml.cc/Conferences/2025/ReviewerInstructions) | 审稿表、评估 |
| 样式与作者说明 | [ICML](https://icml.cc/Conferences/2022/StyleAuthorInstructions) | 格式规范 |

### ICLR

| 文档 | URL | 用途 |
|----------|-----|---------|
| 作者指南 2026 | [ICLR](https://iclr.cc/Conferences/2026/AuthorGuide) | 投稿要求、LLM 披露 |
| 审稿人指南 2025 | [ICLR](https://iclr.cc/Conferences/2025/ReviewerGuide) | 审稿流程、评估 |

### ACL/EMNLP

| 文档 | URL | 用途 |
|----------|-----|---------|
| ACL 样式文件 | [GitHub](https://github.com/acl-org/acl-style-files) | LaTeX 模板 |
| ACL 滚动审稿 | [ARR](https://aclrollingreview.org/) | 投稿流程 |

### AAAI

| 文档 | URL | 用途 |
|----------|-----|---------|
| 作者工具包 2026 | [AAAI](https://aaai.org/authorkit26/) | 模板与指南 |

### COLM

| 文档 | URL | 用途 |
|----------|-----|--------|
| 模板 | [GitHub](https://github.com/COLM-org/Template) | LaTeX 模板 |

### 系统会议（OSDI、NSDI、ASPLOS、SOSP）

系统会议来源已迁移至 [systems-paper-writing](../../systems-paper-writing/) 技能。CFP 链接和模板请参见 [systems-conferences.md](../../systems-paper-writing/references/systems-conferences.md)。

---

## 引用 API 与工具

### API

| API | 文档 | 最适用场景 |
|-----|---------------|----------|
| **Semantic Scholar** | [文档](https://api.semanticscholar.org/api-docs/) | ML/AI 论文、引用图谱 |
| **CrossRef** | [文档](https://www.crossref.org/documentation/retrieve-metadata/rest-api/) | DOI 查询、BibTeX 检索 |
| **arXiv** | [文档](https://info.arxiv.org/help/api/basics.html) | 预印本、PDF 访问 |
| **OpenAlex** | [文档](https://docs.openalex.org/) | 开放替代方案、批量访问 |

### Python 库

| 库 | 安装 | 用途 |
|---------|---------|---------|
| `semanticscholar` | `pip install semanticscholar` | Semantic Scholar 封装器 |
| `arxiv` | `pip install arxiv` | arXiv 搜索与下载 |
| `habanero` | `pip install habanero` | CrossRef 客户端 |

### 引用验证

| 工具 | URL | 用途 |
|------|-----|---------|
| Citely | [citely.ai](https://citely.ai/citation-checker) | 批量验证 |
| ReciteWorks | [reciteworks.com](https://reciteworks.com/) | 正文内引用检查 |

---

## 可视化与格式化

### 图表创建

| 工具 | URL | 用途 |
|------|-----|---------|
| PlotNeuralNet | [GitHub](https://github.com/HarisIqbal88/PlotNeuralNet) | TikZ 神经网络图 |
| SciencePlots | [GitHub](https://github.com/garrettj403/SciencePlots) | 出版级 matplotlib |
| Okabe-Ito 调色板 | [参考](https://jfly.uni-koeln.de/color/) | 色盲友好配色 |

### LaTeX 参考资源

| 资源 | URL | 用途 |
|----------|-----|---------|
| Overleaf 模板 | [Overleaf](https://www.overleaf.com/latex/templates) | 在线 LaTeX 编辑器 |
| BibLaTeX 指南 | [CTAN](https://ctan.org/pkg/biblatex) | 现代引用管理 |

---

## AI 写作与幻觉研究

| 来源 | URL | 核心发现 |
|--------|-----|-------------|
| AI 引用幻觉 | [Enago](https://www.enago.com/academy/ai-hallucinations-research-citations/) | 约 40% 错误率 |
| AI 写作中的幻觉 | [PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10726751/) | 引用错误类型 |
| NeurIPS 2025 AI 报告 | [ByteIota](https://byteiota.com/neurips-2025-100-ai-hallucinations-slip-through-review/) | 100+ 幻觉引用 |

---

## 按主题快速查阅

### 叙事与结构
→ 推荐从以下开始：Neel Nanda、Sebastian Farquhar、Andrej Karpathy

### 句子级清晰度
→ 推荐从以下开始：Gopen & Swan、Ethan Perez、Zachary Lipton

### 词语选择与风格
→ 推荐从以下开始：Zachary Lipton、Jacob Steinhardt

### 会议特定要求
→ ML/AI：从官方会议指南开始（NeurIPS、ICML、ICLR、ACL）
→ 系统会议（OSDI、NSDI、ASPLOS、SOSP）：参见 systems-paper-writing 技能

### 引用管理
→ 推荐从以下开始：Semantic Scholar API、CrossRef、citation-workflow.md

### 审稿人期望
→ 推荐从以下开始：会议审稿人指南、reviewer-guidelines.md
