---
name: 学术绘图
description: 通过 Gemini 和 matplotlib/seaborn 生成符合发表标准的 ML 图表。适用于为 ML 论文创建示意图或图表。
version: 1.0.0
author: Orchestra Research
license: MIT
tags: [学术写作, 可视化, Matplotlib, Seaborn, 绘图, 图表, 示意图, NeurIPS, ICML, ICLR, LaTeX]
dependencies: [matplotlib>=3.8.0, seaborn>=0.13.0, numpy, google-genai>=1.0.0]
---

# ML 论文学术绘图

为 ML/AI 会议论文生成符合发表标准的图表。提供两种独立工作流：

1. **示意图**（架构图、系统设计图、工作流、流程图）—— 通过 Gemini 进行 AI 图像生成
2. **数据图**（折线图、柱状图、散点图、热力图、消融实验图）—— 使用 matplotlib/seaborn

## 选择工作流

| 图表类型 | 工具 | 原因 |
|-------------|------|-----|
| 架构图 / 系统示意图 | Gemini（工作流 1） | 包含方框、箭头、标签的复杂空间布局 |
| 工作流 / 流程 / 生命周期 | Gemini（工作流 1） | 带连接的多步骤流程 |
| 柱状图、折线图、散点图 | matplotlib（工作流 2） | 精确数值数据，可复现 |
| 热力图、混淆矩阵 | matplotlib/seaborn（工作流 2） | 结构化网格数据 |
| 消融实验表格转图表 | matplotlib（工作流 2） | 分组柱状图或折线对比 |
| 饼图 / 环形图 | matplotlib（工作流 2） | 比例数据（在 ML 论文中慎用） |
| 训练曲线 | matplotlib（工作流 2） | 损失/精度随步骤/轮次的变化 |

**经验法则**：若图表有数值坐标轴，使用 matplotlib；若图表含方框和箭头，使用 Gemini。

---

## 步骤 0：上下文分析与信息提取

用户通常提供以下某种输入——而非现成的规格说明：

| 输入类型 | 示例 | 需提取的内容 |
|-----------|---------|-----------------|
| 完整论文 / 章节草稿 | "以下是我们的方法章节……" | 系统组件、组件关系、数据流 |
| 描述段落 | "我们的系统有三个层级，分别……" | 关键实体、层级结构、连接关系 |
| 原始结果 / 数据表 | "MMLU: 85.2, HumanEval: 72.1……" | 指标、方法、对比结构 |
| CSV / JSON 数据 | 实验日志文件 | 变量、趋势、分组维度 |
| 模糊请求 | "为概述部分做一张图" | 读取周边论文上下文以推断内容 |

### 提取工作流

**针对示意图**（研究背景 → 架构图）：

1. **阅读提供的上下文** —— 论文章节、摘要或描述段落
2. **识别视觉实体** —— 主要组件/模块/阶段有哪些？
   - 关注：代表系统部件的名词、命名模块、层级、阶段
   - 计数：若顶层实体超过 8 个，考虑分组
3. **识别关系** —— 各组件如何连接？
   - 关注：描述数据流的动词（"发送至"、"查询"、"输入到"）
   - 分类：数据流（实线箭头）、控制流（灰色）、错误路径（红色虚线）
4. **确定布局模式**：
   - 顺序流程 → 从左到右
   - 分层架构 → 水平带状堆叠
   - 轮辐式 → 中心节点向外辐射连接
   - 层级式 → 自顶向下树形结构
5. **分配颜色** —— 每个逻辑分组/层级使用一种强调色
6. **精确写出每个标签** —— 从论文文本中提取准确术语

**针对数据图**（结果 → 图表）：

1. **阅读提供的数据** —— 表格、含数字的段落、CSV 或 JSON
2. **识别维度**：
   - 比较对象是什么？（方法、模型、配置）→ 分类坐标轴
   - 指标是什么？（准确率、损失、延迟、F1）→ 数值坐标轴
   - 是否有时间/步骤维度？→ 折线图
   - 是否有多个指标？→ 多面板或分组柱状图
3. **按以下优先级自动选择图表类型**：
   - 有步骤/时间轴 → **折线图**
   - N 种方法在 M 个基准上的对比 → **分组柱状图**
   - 单一排名 → **水平柱状图**（排行榜样式）
   - 两个连续变量间的相关性 → **散点图**
   - 数值方阵 → **热力图**
   - 比例分布 → **堆叠柱状图**（避免饼图）
4. **确定图形尺寸** —— 根据数据密度决定单列还是全宽
5. **突出"本文方法"** —— 识别论文贡献对应的条目，赋予其独特颜色

### 自动识别示例

**上下文 → 示意图**："我们的系统包含 Planner、Executor 和 Verifier。Planner 将计划发送给 Executor，Executor 将结果返回给 Verifier，Verifier 在失败时将反馈传回给 Planner。"
→ 3 个实体，循环布局，虚线反馈箭头 → **工作流 1（Gemini）**

**数据 → 图表**："GPT-4: MMLU 86.4, HumanEval 67.0. Ours: 88.1, 71.2. Llama-3: 79.3, 62.1."
→ 3 种方法 × 2 个基准 → **工作流 2（分组柱状图）**，用珊瑚色突出"Ours"

---

## 工作流 1：架构与系统示意图（AI 图像生成）

使用 Gemini 3 Pro Image Preview 生成示意图。**首先选择视觉风格** —— 这是决定图表是否专业的最关键因素。

### 视觉风格

每篇论文选用一种风格（所有图表应保持一致）：

#### 风格 A："Sketch / 简笔画"（手绘风）

温暖、亲切、易于记忆。适合概览图和系统介绍图。效果如同设计师精心整理过的白板草图。

```
VISUAL STYLE — HAND-DRAWN SKETCH:
- Slightly irregular, hand-drawn line quality — lines wobble gently, not perfectly straight
- Rounded, soft shapes with visible pen strokes (like drawn with a thick felt-tip marker)
- Warm off-white background (#FAFAF7), NOT pure white
- Fill colors are soft watercolor-like washes: muted blue (#D6E4F0), soft peach (#F5DEB3),
  light sage (#D4E6D4), pale lavender (#E6DFF0)
- Borders are dark charcoal (#2C2C2C) with 2-3px line weight, slightly uneven
- Arrows are hand-drawn with slight curves, ending in simple open arrowheads (not filled triangles)
- Text uses a rounded sans-serif font (like Comic Neue or Architects Daughter feel)
- Small doodle-style icons inside boxes: a tiny gear ⚙ for processing, a lightbulb 💡 for ideas,
  a magnifying glass 🔍 for search — rendered as simple line drawings, NOT emoji
- Overall feel: a carefully drawn whiteboard diagram, clean but with personality
- NO clip art, NO stock icons, NO photorealistic elements
```

#### 风格 B："Modern Minimal"（简洁有力）

自信、权威。最适合对精确性要求高的方法图。

```
VISUAL STYLE — MODERN MINIMAL:
- Ultra-clean geometric shapes with crisp edges
- Bold color blocks as backgrounds for sections — NOT just accent bars, but full section fills
  using desaturated tones: slate blue (#E8EDF2), warm sand (#F5F0E8), cool mint (#E8F2EE)
- Component boxes have ROUNDED CORNERS (12px radius), NO visible border — they float on
  the section background using subtle shadow (1px, 4px blur, rgba(0,0,0,0.06))
- ONE accent color per section used sparingly on key elements: Deep blue (#2563EB),
  Emerald (#059669), Amber (#D97706), Rose (#E11D48)
- Arrows are thin (1.5px), dark gray (#6B7280), with small filled circle at source
  and clean arrowhead at target — NOT thick colored arrows
- Typography: Inter or system sans-serif, title 600 weight, body 400 weight
- Labels INSIDE boxes, not beside them
- Generous whitespace — at least 24px between elements
- NO decorative elements, NO icons — let the structure speak
```

#### 风格 C："Illustrated Technical"（图标丰富型）

生动、易于解读。适合教程类论文以及需要自说明的图表。

```
VISUAL STYLE — ILLUSTRATED TECHNICAL:
- Each major component has a small MEANINGFUL ICON drawn in a consistent line-art style
  (single color, 2px stroke, ~24x24px): brain icon for reasoning, database cylinder for storage,
  arrow-loop for iteration, network nodes for communication
- Components sit inside soft rounded rectangles with a LEFT COLOR STRIP (4px wide)
- Background is pure white, but each logical group has a very faint colored region behind it
  (#F8FAFC for blue group, #FFF8F0 for orange group)
- Connections use CURVED bezier paths (not straight lines), colored by SOURCE component
- Key data flows are THICKER (3px) than secondary flows (1px, dashed)
- Small annotation badges on arrows: "×N" for repeated operations, "optional" in italics
- Title labels are ABOVE each section in small caps, letter-spaced
- Overall: like a well-designed API documentation diagram
```

#### 风格 D："Accent Bar"（经典学术风）

默认学术风格。适用于任何会议，灰度打印效果良好。

```
VISUAL STYLE — CLASSIC ACCENT BAR:
- Horizontal section bands stacked vertically, pale gray (#F7F7F5) fill
- Thick colored LEFT ACCENT BAR (8px) distinguishes each section
- Content boxes: white fill, thin #DDD border, 4px rounded corners
- Section palette: Blue #4A90D9, Teal #5BA58B, Amber #D4A252, Slate #7B8794
- Sans-serif typography (Helvetica/Arial), bold titles, regular body
- Colored arrows match their SOURCE section
- Clean, flat, zero decoration
```

### 精选配色方案

**"Ocean Dusk"**（专业、沉静——默认推荐）：
`#264653` 深青色, `#2A9D8F` 青色, `#E9C46A` 金色, `#F4A261` 沙橙色, `#E76F51` 珊瑚色

**"Ink & Wash"**（适用于简笔画风格）：
`#2C2C2C` 墨炭色, `#D6E4F0` 淡蓝色, `#F5DEB3` 淡麦色, `#D4E6D4` 淡鼠尾草绿, `#E6DFF0` 淡薰衣草紫

**"Nord"**（适用于现代简约风格）：
`#2E3440` 极夜黑, `#5E81AC` 霜蓝色, `#A3BE8C` 极光绿, `#EBCB8B` 极光黄, `#BF616A` 极光红

**"Okabe-Ito"**（通用色盲友好配色，数据图必须使用）：
`#E69F00` 橙色, `#56B4E9` 天蓝色, `#009E73` 绿色, `#F0E442` 黄色, `#0072B2` 蓝色, `#D55E00` 朱红色, `#CC79A7` 粉色

### 检查清单

- [ ] **从上下文提取信息**：阅读论文/描述，识别实体和关系
- [ ] **选择视觉风格**（A/B/C/D）—— 与论文基调和投稿会议相匹配
- [ ] **选择配色方案** —— 或使用与论文现有图表一致的配色
- [ ] 获取 Gemini API 密钥（`GEMINI_API_KEY` 环境变量）
- [ ] 撰写详细提示词：风格块 + 布局 + 连接关系 + 约束条件
- [ ] 在 `figures/gen_fig_<name>.py` 生成脚本，运行 3 次
- [ ] 审查，选出最佳结果，保存为 `figures/fig_<name>.png`

### 提示词结构（6 个章节）

每个 Gemini 提示词必须按顺序包含以下章节：

```
1. FRAMING（5 行）："Create a [STYLE_NAME]-style technical diagram for a
   [VENUE] paper. The diagram should feel [ADJECTIVES]..."

2. VISUAL STYLE（20-30 行）：完整复制上方对应风格块（A/B/C/D）。
   这是最重要的章节——它决定了整体视觉风格。

3. COLOR PALETTE（10 行）：所有用色的精确十六进制代码。

4. LAYOUT（50-150 行）：每个组件、方框、章节——精确的文本、
   空间排列和分组。务必详尽具体。

5. CONNECTIONS（30-80 行）：逐一描述每个箭头——来源、目标、
   样式、标签、走向。

6. CONSTRAINTS（10 行）：不应包含的内容。根据风格调整——例如
   简笔画风格允许轻微不规则，但仍不可使用剪贴画。
```

### 生成脚本模板

```python
#!/usr/bin/env python3
"""Generate [FIGURE_NAME] diagram using Gemini image generation."""
import os, sys, time
from google import genai

API_KEY = os.environ.get("GEMINI_API_KEY")
if not API_KEY:
    print("ERROR: Set GEMINI_API_KEY environment variable.")
    print("  Get a key at: https://aistudio.google.com/apikey")
    sys.exit(1)

MODEL = "gemini-3-pro-image-preview"
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
client = genai.Client(api_key=API_KEY)

PROMPT = """
[PASTE YOUR 6-SECTION PROMPT HERE]
"""

def generate_image(prompt_text, attempt_num):
    print(f"\n{'='*60}\nAttempt {attempt_num}\n{'='*60}")
    try:
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt_text,
            config=genai.types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
            ),
        )
        output_path = os.path.join(OUTPUT_DIR, f"fig_NAME_attempt{attempt_num}.png")
        for part in response.candidates[0].content.parts:
            if part.inline_data:
                with open(output_path, "wb") as f:
                    f.write(part.inline_data.data)
                print(f"Saved: {output_path} ({os.path.getsize(output_path):,} bytes)")
                return output_path
            elif part.text:
                print(f"Text: {part.text[:300]}")
        print("WARNING: No image in response")
        return None
    except Exception as e:
        print(f"ERROR: {e}")
        return None

def main():
    results = []
    for i in range(1, 4):
        if i > 1:
            time.sleep(2)
        path = generate_image(PROMPT, i)
        if path:
            results.append(path)
    if not results:
        print("All attempts failed!")
        sys.exit(1)
    print(f"\nGenerated {len(results)} attempts. Review and pick the best.")

if __name__ == "__main__":
    main()
```

### 关键规则

- **始终运行 3 次** —— 每次生成质量差异显著
- **风格块是必须的** —— 缺少它，Gemini 会默认生成通用企业风格
- **切勿硬编码 API 密钥** —— 使用 `os.environ.get("GEMINI_API_KEY")`
- **保存生成脚本** —— 可复现性至关重要
- **精确指定每个标签** —— Gemini 可能拼错或调换文字

**各风格完整提示词示例**：参见 [references/diagram-generation.md](references/diagram-generation.md)

---

## 工作流 2：数据驱动图表（matplotlib/seaborn）

适用于所有含数值数据、坐标轴或定量对比的图表。

### 检查清单

- [ ] **从上下文提取信息**：解析结果/数据，识别方法、指标和对比结构
- [ ] **根据数据维度自动选择图表类型**（参见下方决策指南）
- [ ] 准备数据（CSV、字典或内联数组）
- [ ] 应用发表级样式（字体、颜色、尺寸）
- [ ] 用独特颜色突出"本文方法"
- [ ] 同时导出 PDF（矢量图）和 PNG（300 DPI）
- [ ] 验证与 LaTeX 字体的兼容性
- [ ] 将脚本保存至 `figures/gen_fig_<name>.py`

### 图表类型决策指南

| 数据模式 | 最佳图表 | 备注 |
|-------------|------------|-------|
| 时间/步骤趋势 | 折线图 | 训练曲线、缩放规律 |
| 类别对比 | 分组柱状图 | 模型对比、消融实验 |
| 分布 | 小提琴图 / 箱线图 | 各方法的分数分布 |
| 相关性 | 散点图 | 嵌入分析、指标相关性 |
| 数值网格 | 热力图 | 注意力图、混淆矩阵 |
| 部分与整体 | 堆叠柱状图（非饼图） | ML 论文中优先使用堆叠柱状图 |
| 多方法单指标 | 水平柱状图 | 排行榜样式对比 |

### 发表级样式模板

```python
import matplotlib.pyplot as plt
import numpy as np

# --- Publication defaults (polished, not generic) ---
plt.rcParams.update({
    "font.family": "serif", "font.serif": ["Times New Roman", "DejaVu Serif"],
    "font.size": 10, "axes.titlesize": 11, "axes.titleweight": "bold",
    "axes.labelsize": 10, "legend.fontsize": 8.5, "legend.frameon": False,
    "figure.dpi": 300, "savefig.dpi": 300, "savefig.bbox": "tight",
    "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.alpha": 0.15, "grid.linestyle": "-",
    "lines.linewidth": 1.8, "lines.markersize": 5,
})

# --- "Ocean Dusk" palette (professional, distinctive, colorblind-safe) ---
COLORS = ["#264653", "#2A9D8F", "#E9C46A", "#F4A261", "#E76F51",
          "#0072B2", "#56B4E9", "#8C8C8C"]
OUR_COLOR = "#E76F51"       # coral — warm, stands out
BASELINE_COLOR = "#B0BEC5"  # cool gray — recedes
FIG_SINGLE, FIG_FULL = (3.25, 2.5), (6.75, 2.8)
```

### 常用图表模式

**折线图（训练曲线）** —— 带标记点和置信区间：

```python
fig, ax = plt.subplots(figsize=FIG_SINGLE)
markers = ["o", "s", "^", "D", "v"]
for i, (method, (mean, std)) in enumerate(results.items()):
    color = OUR_COLOR if method == "Ours" else COLORS[i]
    ax.plot(steps, mean, label=method, color=color,
            marker=markers[i % 5], markevery=max(1, len(steps)//8),
            markersize=4, zorder=3)
    ax.fill_between(steps, mean - std, mean + std, color=color, alpha=0.12)
ax.set_xlabel("Training Steps")
ax.set_ylabel("Accuracy (%)")
ax.legend(loc="lower right")
fig.savefig("figures/fig_training.pdf")
fig.savefig("figures/fig_training.png", dpi=300)
```

**分组柱状图（消融实验）** —— 带数值标签：

```python
fig, ax = plt.subplots(figsize=FIG_FULL)
x = np.arange(len(categories))
n = len(methods)
width = 0.7 / n
for i, (method, scores) in enumerate(methods.items()):
    color = OUR_COLOR if method == "Ours" else COLORS[i]
    offset = (i - n / 2 + 0.5) * width
    bars = ax.bar(x + offset, scores, width * 0.9, label=method, color=color,
                  edgecolor="white", linewidth=0.5)
    for bar, s in zip(bars, scores):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.3,
                f"{s:.1f}", ha="center", va="bottom", fontsize=7, color="#444")
ax.set_xticks(x)
ax.set_xticklabels(categories)
ax.set_ylabel("Score")
ax.legend(ncol=min(n, 4))
fig.savefig("figures/fig_ablation.pdf")
```

**热力图** —— 发散色映射与简洁边框：

```python
import seaborn as sns
fig, ax = plt.subplots(figsize=(4, 3.5))
sns.heatmap(matrix, annot=True, fmt=".2f", cmap="YlOrRd", ax=ax,
            cbar_kws={"shrink": 0.75, "aspect": 20},
            linewidths=1.5, linecolor="white",
            annot_kws={"size": 8, "weight": "medium"})
ax.set_xlabel("Predicted")
ax.set_ylabel("Actual")
fig.savefig("figures/fig_confusion.pdf")
```

**水平柱状图（排行榜）** —— 突出"本文方法"：

```python
fig, ax = plt.subplots(figsize=FIG_SINGLE)
y_pos = np.arange(len(models))
colors = [BASELINE_COLOR] * len(models)
colors[our_idx] = OUR_COLOR
bars = ax.barh(y_pos, scores, color=colors, height=0.55,
               edgecolor="white", linewidth=0.5)
ax.set_yticks(y_pos)
ax.set_yticklabels(models)
ax.set_xlabel("Accuracy (%)")
ax.invert_yaxis()
for bar, s in zip(bars, scores):
    ax.text(bar.get_width() + 0.3, bar.get_y() + bar.get_height()/2,
            f"{s:.1f}", va="center", fontsize=8, color="#444")
fig.savefig("figures/fig_leaderboard.pdf")
```

**完整模式库**（缩放规律、小提琴图、多面板、雷达图）：参见 [references/data-visualization.md](references/data-visualization.md)

---

## 发表样式快速参考

| 会议 | 单列宽度 | 全宽 | 字体 |
|-------|-----------|------------|------|
| NeurIPS | 5.5 in | 5.5 in | Times |
| ICML | 3.25 in | 6.75 in | Times |
| ICLR | 5.5 in | 5.5 in | Times |
| ACL | 3.3 in | 6.8 in | Times |
| AAAI | 3.3 in | 7.0 in | Times |

**始终导出 PDF** 以获得矢量质量。PNG 仅用于 AI 生成的示意图。

**各会议详细规范、LaTeX 集成、字体匹配、无障碍检查清单**：参见 [references/style-guide.md](references/style-guide.md)

---

## 常见问题

| 问题 | 解决方案 |
|-------|----------|
| LaTeX 中字体显示异常 | 导出 PDF，设置 `text.usetex=True`，或使用 `font.family=serif` |
| 图形超出列宽 | 检查会议宽度限制，以英寸为单位设置 `figsize` |
| 打印时颜色无法区分 | 使用色盲友好配色 + 不同线型/标记 |
| Gemini 拼错标签 | 在提示词中逐字写出每个标签，添加"SPELL EXACTLY"约束 |
| Gemini 忽略风格设定 | 增加更多负向约束，更具体地指定十六进制颜色 |
| PDF 中图形模糊 | 导出为 PDF（矢量图）而非 PNG；或对 PNG 使用 300+ DPI |
| 图例遮挡数据 | 使用 `bbox_to_anchor`、`loc="upper left"` 或外置图例 |
| 刻度标签过多 | 使用 `ax.xaxis.set_major_locator(MaxNLocator(5))` |

## 适用场景与替代方案

| 需求 | 本技能 | 替代方案 |
|------|-----------|-------------|
| 架构示意图 | Gemini 生成 | TikZ（手动）、draw.io（交互式）、Mermaid（简单图） |
| 数据图表 | matplotlib/seaborn | Plotly（交互式）、R/ggplot2（统计密集型） |
| 完整论文写作 | 配合 `ml-paper-writing` 使用 | — |
| 海报图表 | 更大字体、更宽尺寸 | `latex-posters` 技能 |
| 演示文稿图表 | 更大文字、更少细节 | PowerPoint/Keynote 导出 |

---

## 快速参考：文件命名规范

```
figures/
├── gen_fig_<name>.py      # Generation script (always save for reproducibility)
├── fig_<name>.pdf         # Final vector output (for LaTeX)
├── fig_<name>.png         # Raster output (300 DPI, for AI-generated or fallback)
└── fig_<name>_attempt*.png # Gemini attempts (keep for comparison)
```

---
如未收到具体问题，直接询问："您在使用 [工具名称] 时遇到了什么问题或需要构建什么？请分享您的代码、配置或错误信息。"
