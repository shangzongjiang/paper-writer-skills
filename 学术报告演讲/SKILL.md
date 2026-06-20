---
name: 学术报告演讲
description: 从论文生成 Beamer LaTeX PDF 和 PPTX 幻灯片（含演讲备注）。适用于机器学习/系统领域的学术会议报告。
version: 1.0.0
author: Orchestra Research
license: MIT
tags: [学术报告演讲, Beamer, PPTX, 幻灯片, 演讲备注, OSDI, SOSP, ASPLOS, NeurIPS, ICML]
dependencies: [python-pptx>=0.6.21]
---

# 学术报告演讲：从论文到幻灯片

从已编译的研究论文生成会议演讲幻灯片。同时输出 **Beamer LaTeX PDF**（精美排版）和**可编辑 PPTX**（便于临时调整），并附带演讲备注和可选的完整演讲稿。

## 适用场景

| 场景 | 使用本技能 | 改用其他技能 |
|------|-----------|-------------|
| 准备口头报告/聚光灯报告/海报报告幻灯片 | ✅ | |
| 从论文生成 Beamer PDF + PPTX | ✅ | |
| 演讲备注与演讲稿 | ✅ | |
| 撰写论文本身 | | ml-paper-writing |
| 系统类论文结构规划 | | systems-paper-writing |
| 制作出版质量的图表 | | academic-plotting |

**致谢**：本技能的结构借鉴了 ARIS paper-slides skill（570 行，支持 poster/spotlight/oral/invited 多种形式，结合 Beamer+PPTX）。本实现为 AI-Research-SKILLs 生态系统的独立版本。

---

## 报告类型与幻灯片数量

| 报告类型 | 时长 | 幻灯片数 | 内容深度 |
|----------|------|----------|----------|
| poster-talk（海报报告） | 3–5 分钟 | 5–8 | 仅介绍问题与核心结果 |
| spotlight（聚光灯报告） | 5–8 分钟 | 8–12 | 问题 + 方法 + 关键结果 |
| oral（口头报告） | 15–20 分钟 | 15–22 | 完整叙事 + 实验亮点 |
| invited（特邀报告） | 30–45 分钟 | 25–40 | 深度讲解 + 背景介绍 + 演示 |

**经验法则**：口头报告约每分钟 1 张幻灯片，聚光灯报告约每分钟 1.5 张。

---

## 幻灯片结构模板

### 海报报告（5–8 张幻灯片）

```text
第 1 张: 标题 + 作者 + 机构
第 2 张: 问题 — 为什么重要（1 张动机图）
第 3 张: 核心洞察 — 一句话论点
第 4 张: 方法概述 — 架构图
第 5 张: 主要结果 — 核心数据（1 张图）
第 6 张: 结论 + 论文/代码二维码
```

### 聚光灯报告（8–12 张幻灯片）

```text
第 1 张:  标题 + 作者
第 2 张:  问题陈述 — 具体、量化
第 3 张:  动机 — 现有方案的不足
第 4 张:  核心洞察 — 论点声明
第 5 张:  系统概述 — 架构图
第 6 张:  设计亮点 1 — 核心机制
第 7 张:  设计亮点 2 — 关键创新
第 8 张:  实验设置 — 基线与负载（简要）
第 9 张:  主要结果 — 性能核心图
第 10 张: 消融/细分 — 贡献最大的部分
第 11 张: 总结 + 贡献点
第 12 张: 致谢 + 相关链接
```

### 口头报告（15–22 张幻灯片）

```text
第 1 张:  标题 + 作者 + 会议
第 2 张:  大纲（可选——"路线图"幻灯片）
第 3 张:  问题背景 — 领域重要性
第 4 张:  问题陈述 — 具体挑战
第 5 张:  动机 — 现有系统的不足
第 6 张:  核心洞察 — 论点
第 7 张:  系统概述 — 架构图
第 8 张:  设计组件 1 — 详细讲解
第 9 张:  设计组件 2 — 详细讲解
第 10 张: 设计组件 3 — 详细讲解
第 11 张: 设计替代方案 — 为何不采用其他方案
第 12 张: 实现 — 关键工程亮点
第 13 张: 实验设置 — 测试平台、基线、指标
第 14 张: 端到端结果 — 主要性能
第 15 张: 结果深挖 — 细分或逐负载分析
第 16 张: 消融研究 — 各组件贡献
第 17 张: 扩展性 — 规模化表现
第 18 张: 演示幻灯片（系统类报告）— 截图或录屏
第 19 张: 相关工作 — 定位（简要）
第 20 张: 总结 — 贡献点重述
第 21 张: 未来工作 — 开放性问题
第 22 张: 致谢 + 论文链接 + 二维码
```

### 特邀报告（25–40 张幻灯片）
在口头报告结构基础上扩展：
- 额外的背景幻灯片（领域综述、历史进展）
- 多张演示/演练幻灯片
- 更深入的实验分析
- 更宏观的影响与未来方向探讨
- 问答备用幻灯片（隐藏，用于应急）

---

## 系统类报告的特殊要求

系统类会议报告与机器学习报告相比有独特要求：

### 演示幻灯片
- 包含系统实际运行的**现场演示**或**预录屏幕录像**
- 始终准备**录像备份**——现场演示往往在关键时刻出问题
- 在真实负载下展示系统，避免使用玩具示例

### 架构讲解
- 对架构图做动态演示：讲解时逐步高亮各组件
- 使用 Beamer 的 `\only<N>` 或 `\onslide<N>` 实现逐步展示
- 端到端演示一个**具体请求**如何流经整个系统

### 实验亮点
- 从论文中选取 2–3 张最有力的图
- 在幻灯片上标注图示（箭头、圆圈高亮关键点）
- **先说结论再展示数据**（如 "我们的系统快 2 倍——以下是数据"）

---

## 演讲备注指南

### 每张幻灯片的结构
```text
[计时: X 分钟]
[需要传达的核心要点]
[过渡到下一张幻灯片的衔接语]
```

### Mike Dahlin 的分层法
在三个层面运用"先预告、再讲解、后总结"：

1. **报告层面**：大纲幻灯片 → 正文 → 总结幻灯片
2. **章节层面**：章节标题 → 内容幻灯片 → 章节要点
3. **幻灯片层面**：标题陈述 → 支撑证据 → 过渡衔接

### 计时建议
- 海报报告：每张 30–60 秒
- 聚光灯报告：每张 30–45 秒
- 口头报告：每张 45–90 秒
- 特邀报告：每张 60–120 秒

---

## 输出格式

### Beamer LaTeX → PDF

优势：专业排版，支持数学公式，便于版本控制。

```latex
\documentclass[aspectratio=169]{beamer}
\usetheme{metropolis}  % 简洁现代主题
\usepackage{appendixnumberbeamer}

\title{Your Paper Title}
\subtitle{Venue Year}
\author{Author 1 \and Author 2}
\institute{Institution}
\date{}

\begin{document}
\maketitle

\begin{frame}{Problem}
  \begin{itemize}
    \item Key problem statement
    \item Concrete motivation with numbers
  \end{itemize}
  \note{Speaker note: Start with the big picture...}
\end{frame}

% ... 更多帧 ...
\end{document}
```

### python-pptx → 可编辑 PPTX

优势：易于临时修改，兼容企业模板，支持动画。

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN

prs = Presentation()
prs.slide_width = Inches(13.333)  # 16:9
prs.slide_height = Inches(7.5)

# 标题幻灯片
slide = prs.slides.add_slide(prs.slide_layouts[0])
slide.shapes.title.text = "Your Paper Title"
slide.placeholders[1].text = "Author 1, Author 2\nVenue Year"

# 内容幻灯片
slide = prs.slides.add_slide(prs.slide_layouts[1])
slide.shapes.title.text = "Problem Statement"
body = slide.placeholders[1]
body.text = "Key point 1\nKey point 2"

# 添加演讲备注
notes_slide = slide.notes_slide
notes_slide.notes_text_frame.text = "Speaker note: explain the motivation..."

prs.save("talk.pptx")
```

---

## 配色方案建议

> 以下为美学建议，非官方会议要求。可自由调整。

| 会议类型 | 主色 | 强调色 | 背景色 |
|----------|------|--------|--------|
| USENIX（OSDI/NSDI） | 深蓝（#003366） | 红（#CC0000） | 白 |
| ACM（SOSP/ASPLOS） | ACM 蓝（#0071BC） | 深灰（#333333） | 白 |
| NeurIPS | 紫（#7B2D8E） | 金（#F0AD00） | 白 |
| ICML | 青绿（#008080） | 橙（#FF6600） | 白 |
| 通用 | 深灰（#333333） | 蓝（#0066CC） | 白 |

---

## 工作流

### 步骤 1：内容提取
```text
- 阅读已编译的论文（PDF 或 LaTeX 源文件）
- 识别：论点、贡献、架构图、关键实验图
- 确认报告类型和时长
```

### 步骤 2：大纲生成
```text
- 选择合适的幻灯片结构模板（见上文）
- 将论文各节映射到幻灯片组
- 为每组幻灯片分配时间
```

### 步骤 3：逐张生成幻灯片
```text
- 逐张生成 Beamer 源代码
- 为每张幻灯片添加演讲备注
- 将论文中的图表复制到 slides/ 目录
- 生成对应的 python-pptx 脚本用于 PPTX 版本
```

### 步骤 4：审核与润色
```text
- 检查总幻灯片数是否符合报告时长
- 确认所有图表在演示分辨率下清晰可读
- 运行 Beamer 编译：latexmk -pdf slides.tex
- 运行 PPTX 生成：python3 generate_slides.py
- 检查演讲备注的计时与过渡
```

### 快速检查清单
- [ ] 幻灯片数量与报告类型/时长相符
- [ ] 标题幻灯片包含正确的作者、机构、会议信息
- [ ] 包含架构图且标注清晰
- [ ] 关键实验图标注了结论要点
- [ ] 演讲备注包含计时标记
- [ ] 各节之间过渡流畅
- [ ] 演示幻灯片有录像备份
- [ ] 致谢幻灯片包含论文链接/二维码
- [ ] 字号 ≥ 24pt，确保坐在后排也能看清
- [ ] 全程配色方案一致

---

## 常见问题与解决方案

| 问题 | 解决方案 |
|------|----------|
| 幻灯片数量超出时限 | 删减细节，每个论点保留一张图 |
| 幻灯片像论文段落 | 使用要点（每张 ≤6 条），让图表讲故事 |
| 设计部分听众跟不上 | 添加逐步展示的架构讲解 |
| 实验幻灯片信息量过大 | 展示 2–3 张最强图，其余放入备用幻灯片 |
| 演讲备注过长 | 目标每张 3–4 句，聚焦过渡衔接 |
| Beamer 编译失败 | 检查图片路径，使用 `\graphicspath{{figures/}}` |
| PPTX 与 Beamer 外观不一致 | 手动调整 python-pptx 字号和边距 |

---

## 参考资源

- [references/slide-templates.md](references/slide-templates.md) — 完整的 Beamer 模板代码和 python-pptx 生成脚本
- Mike Dahlin，"Giving a Conference Talk" — https://www.cs.utexas.edu/~dahlin/professional/goodTalk.pdf

---
如未收到具体问题，直接询问："你正在使用会议报告幻灯片构建或调试什么？请分享你的代码、配置或报错信息。"
