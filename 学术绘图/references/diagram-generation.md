# AI 驱动的图表生成指南

完整的提示词工程参考，用于生成独特的、达到发表水准的图表。

## 为什么提示词比任何因素都重要

同一个 Gemini 模型会因提示词质量的不同而产生截然不同的结果：
- **通用提示词** → 颜色随机、平淡无奇的企业流程图
- **风格专属提示词** → 独特、令人印象深刻、视觉风格统一的图形

提示词开头的风格描述块是最关键的单一因素。

## 模型选择

| 模型 | 最适用场景 | 备注 |
|-------|----------|-------|
| `gemini-3-pro-image-preview` | 所有技术图表 | 文字渲染最佳，结构还原度最高 |
| DALL-E 3 | 概念性插图 | 美学效果更佳，但精确文字排版较弱 |

## 提示词结构（6 个部分）

### 第 1 部分：框架设定（5-10 行）

确立基调与背景，塑造模型的整体处理方式。

**简笔画风格**：
```
Create a warm, hand-drawn-style technical diagram for a NeurIPS machine learning
paper. The diagram should feel like a carefully drawn whiteboard sketch —
approachable and clear, with personality in the line work, but still precise
enough for a top venue. Think: the kind of diagram a brilliant researcher would
draw during a coffee chat to explain their system.
```

**现代简约风格**：
```
Create an ultra-clean, modern technical architecture diagram for an ICML paper.
The diagram should feel like a premium design system — confident, spacious, and
authoritative. Think: Apple's developer documentation meets a Nature paper.
Every element earns its space. No visual noise.
```

**插画技术风格**：
```
Create a richly illustrated technical diagram for an ICLR paper. Each component
should have a small, meaningful line-art icon that helps the reader instantly
understand its purpose. The diagram should be self-explanatory — a reader should
grasp the system architecture just by looking at the figure, before reading the
caption. Think: the best technical documentation you've ever seen.
```

### 第 2 部分：视觉风格（20-40 行）

这是**最重要**的部分。从 SKILL.md 复制完整的风格描述块，并补充更多细节。对视觉特征的描述要极为具体。

**核心原则**：描述图表的*感觉*与*质感*，而不仅仅是几何形状。

好的写法："Lines should wobble gently like drawn with a thick felt-tip marker on smooth paper"
差的写法："Lines should be slightly irregular"

好的写法："Fill colors are soft watercolor-like washes — imagine diluted ink bleeding into damp paper"
差的写法："Use light colors"

好的写法："Components float on the background with barely-there shadows (1px offset, 6px blur, 3% opacity)"
差的写法："Add subtle shadows"

### 第 3 部分：色彩方案（10-15 行）

始终指定精确的十六进制色值，绝不将颜色选择交由模型自行决定。

**"海洋黄昏"色板**（专业、沉稳）：
```
COLOR PALETTE (use EXACTLY these colors, no substitutions):
- Primary components: Deep Teal #264653
- Secondary components: Teal #2A9D8F
- Accent / highlights: Gold #E9C46A
- Warm connections: Sandy Orange #F4A261
- Alert / error paths: Burnt Coral #E76F51
- Backgrounds: Warm off-white #FAFAF7
- Text primary: Nearly black #1A1A2E
- Text secondary: Warm gray #6B7280
- Borders (if any): Soft gray #E5E7EB
```

**"水墨渲染"色板**（适用于简笔画）：
```
COLOR PALETTE — INK AND WASH:
- All outlines and text: Charcoal ink #2C2C2C
- Wash fill 1: Diluted blue #D6E4F0 (like watercolor blue, very soft)
- Wash fill 2: Warm wheat #F5DEB3 (like tea-stained paper)
- Wash fill 3: Soft sage #D4E6D4 (like pale green ink wash)
- Wash fill 4: Faint lavender #E6DFF0 (like diluted purple ink)
- Background: Warm paper #FAFAF7 (NOT pure white — should feel like quality drawing paper)
- Accent marks: Terracotta #C0725E (used sparingly for emphasis)
```

**"Nord"色板**（适用于现代简约）：
```
COLOR PALETTE — NORD:
- Primary: Polar Night #2E3440
- Section fills: Snow Storm #ECEFF4, #E5E9F0, #D8DEE9
- Accent Blue: Frost #5E81AC
- Accent Green: Aurora #A3BE8C
- Accent Yellow: Aurora #EBCB8B
- Accent Red: Aurora #BF616A
- Text: Polar Night #2E3440
- Subtle text: #4C566A
```

### 第 4 部分：布局描述（50-150 行）

**务必极度具体。** 大多数提示词在此部分失败，原因往往是描述过于模糊。

布局描述的写作规则：
1. **为每个方框命名**，并注明确切的文字内容
2. **明确说明空间关系**（"方框 A 在方框 B 的左侧"）
3. **为每个组件补充副标题/说明**
4. **描述分组关系**（"这 3 个方框位于标注为 X 的区域内"）
5. **相对指定尺寸**（"宽高比约为 2:1"）

**示例（简笔画风格）**：
```
LAYOUT — THREE-STAGE PIPELINE (left to right):

The diagram flows LEFT to RIGHT across three main stages, with a feedback loop
curving back from right to left at the bottom.

STAGE 1 — "Observe" (left third of diagram):
- Draw a rounded blob (not a rectangle!) with soft blue wash fill (#D6E4F0)
- Inside the blob: hand-drawn icon of an EYE (simple line drawing, 3 curved lines)
- Below the icon: "Observe" in bold charcoal
- Below that: "Gather signals from environment" in smaller text
- A small stack of paper sheets icon to the lower-right of the blob,
  labeled "Raw Data" with a tiny arrow pointing into the blob

STAGE 2 — "Hypothesize" (middle third):
- Draw a rounded blob with warm wheat wash fill (#F5DEB3)
- Inside: hand-drawn LIGHTBULB icon (simple: circle + filament lines + base)
- Below: "Hypothesize" in bold
- Below: "Form testable predictions" in smaller text
- Two small thought-bubble circles trailing from the blob upward,
  suggesting the thinking process

STAGE 3 — "Verify" (right third):
- Draw a rounded blob with sage wash fill (#D4E6D4)
- Inside: hand-drawn CHECKMARK icon (a satisfying thick check)
- Below: "Verify" in bold
- Below: "Test against evidence" in smaller text

FEEDBACK LOOP:
- A long curved dashed arrow from "Verify" back to "Observe",
  curving BELOW the three stages
- Label on the arrow: "refine & iterate" in italic
- The arrow should feel like a casual hand-drawn curve, not a geometric arc
```

### 第 5 部分：连接关系（30-80 行）

逐一描述每条箭头。箭头承载着图表的语义信息。

**单条箭头的描述模板**：
```
ARROW [N]: [Source] → [Target]
- Style: [solid / dashed / dotted]
- Color: [hex code]
- Weight: [thin 1px / medium 2px / thick 3px]
- Routing: [straight / curves UP / curves DOWN / bezier around X]
- Label: "[text]" in [italic / bold], positioned [above / below / alongside]
- Arrowhead: [filled triangle / open chevron / circle dot]
```

**各风格箭头约定**：

| 风格 | 箭头特征 |
|-------|----------------|
| 简笔画 | 手绘曲线、开放式箭头、标签采用随意手写风格 |
| 现代简约 | 细灰色（`#6B7280`）直线，起点为小实心圆，终点为简洁折线箭头 |
| 插画技术 | 与起始端颜色一致的贝塞尔曲线，中等粗细，标签带徽章 |
| 经典学术 | 与所在区域颜色一致的实色线条，实心三角箭头 |

### 第 6 部分：约束条件（10-15 行）

根据所选风格调整约束条件：

**简笔画风格**：
```
CONSTRAINTS:
- Lines should look HAND-DRAWN but still legible — wobbly, not chaotic
- NO clip art, NO stock icons, NO photorealistic elements
- NO emoji — icons must be simple LINE DRAWINGS in charcoal
- NO figure numbers, NO captions, NO watermarks
- Background is warm off-white #FAFAF7, NOT pure white
- Overall composition should feel warm and inviting, like a sketchbook page
- Every text label spelled EXACTLY as specified
- Publication quality — this is for NeurIPS, not a napkin sketch
```

**现代简约风格**：
```
CONSTRAINTS:
- ZERO decoration — no icons, no illustrations, no ornaments
- NO visible borders on component boxes — they float using subtle shadow only
- NO thick colored lines — all connections are thin gray
- NO gradients, NO patterns, NO textures
- Whitespace is a design element — at least 24px between all elements
- NO figure numbers, NO captions, NO watermarks
- Background pure white #FFFFFF
- Every text label spelled EXACTLY as specified
```

## 完整提示词示例

### 示例 1：智能体系统（简笔画风格）

```
Create a warm, hand-drawn-style technical diagram for a NeurIPS paper showing
an autonomous research agent system. The diagram should feel like a carefully
drawn whiteboard sketch — approachable yet precise.

VISUAL STYLE — HAND-DRAWN SKETCH:
- Slightly irregular, hand-drawn line quality — lines wobble gently, not perfectly straight
- Rounded, soft shapes with visible pen strokes (like drawn with a thick felt-tip marker)
- Warm off-white background (#FAFAF7)
- Fill colors are soft watercolor washes: blue #D6E4F0, wheat #F5DEB3, sage #D4E6D4
- Borders are charcoal #2C2C2C, 2-3px, slightly uneven
- Arrows hand-drawn with natural curves, open arrowheads
- Small doodle-style line-art icons inside each component (NOT emoji, NOT clip art)
- Text in rounded sans-serif, warm and readable

COLOR PALETTE — INK AND WASH:
- Outlines/text: Charcoal #2C2C2C
- Planner fill: Blue wash #D6E4F0
- Executor fill: Wheat wash #F5DEB3
- Verifier fill: Sage wash #D4E6D4
- Background: Warm paper #FAFAF7
- Failure/retry: Terracotta #C0725E

LAYOUT — TRIANGULAR ARRANGEMENT:
Three rounded blob shapes arranged in a triangle:

TOP CENTER — "Planner" blob:
- Blue wash fill (#D6E4F0)
- Line-art icon: a small COMPASS or MAP (simple 2D line drawing)
- Bold label: "Planner"
- Subtitle: "Decomposes research questions"

BOTTOM LEFT — "Executor" blob:
- Wheat wash fill (#F5DEB3)
- Line-art icon: a small GEAR or WRENCH
- Bold label: "Executor"
- Subtitle: "Runs experiments & tools"

BOTTOM RIGHT — "Verifier" blob:
- Sage wash fill (#D4E6D4)
- Line-art icon: a small MAGNIFYING GLASS
- Bold label: "Verifier"
- Subtitle: "Checks results & evidence"

ARROWS:
1. Planner → Executor: curved arrow going DOWN-LEFT, charcoal, solid
   Label: "task plan" (italic, small)
2. Executor → Verifier: curved arrow going RIGHT, charcoal, solid
   Label: "raw results" (italic, small)
3. Verifier → Planner: curved arrow going UP-LEFT, terracotta #C0725E, DASHED
   Label: "needs revision" (italic, small)
   This is the feedback/retry path — dashed to show it's conditional

CENTER of triangle: small text "Shared Memory" with a tiny notebook icon

CONSTRAINTS:
- Hand-drawn feel but still publication quality for NeurIPS
- NO clip art, NO stock icons — only simple line drawings
- NO figure numbers, NO captions
- Warm off-white background, NOT pure white
- Every label spelled EXACTLY as written
```

### 示例 2：训练流程（现代简约风格）

```
Create an ultra-clean, modern technical architecture diagram for an ICML paper.
Confident, spacious, authoritative. Think: Apple developer docs meets Nature paper.

VISUAL STYLE — MODERN MINIMAL:
- Ultra-clean geometric shapes with crisp edges
- Bold color blocks as section fills using desaturated tones
- Component boxes: 12px rounded corners, NO visible border, float on section
  background with subtle shadow (1px, 4px blur, rgba(0,0,0,0.06))
- ONE accent color per section, used on section header only
- Arrows: thin 1.5px, dark gray #6B7280, small filled circle at source,
  clean open chevron at target
- Typography: system sans-serif, titles 600 weight, body 400 weight
- Labels INSIDE boxes, generous whitespace (24px+ between elements)

COLOR PALETTE — NORD:
- Deep text: #2E3440
- Section 1 fill: #EEF1F6 (blue tint), accent: #5E81AC
- Section 2 fill: #EDF3ED (green tint), accent: #A3BE8C
- Section 3 fill: #F5F2EA (yellow tint), accent: #EBCB8B
- Box fill: White #FFFFFF
- Arrows: #6B7280

LAYOUT — THREE HORIZONTAL SECTIONS:
Three wide horizontal bands, stacked vertically with 16px gaps.
Each section is a full-width rounded rectangle (8px corners).

[SECTION 1 — "Data" — blue tint background #EEF1F6]
- Small section header top-left: "DATA" in #5E81AC, small caps, letter-spaced
- Three white floating boxes in a row:
  Box: "Corpus" / "1.2T tokens"
  Box: "Filter" / "Quality + dedup"
  Box: "Tokenize" / "BPE 32K"

[SECTION 2 — "Train" — green tint background #EDF3ED]
- Header: "TRAIN" in #A3BE8C
- Three white floating boxes:
  Box: "Model" / "7B · 32 layers"
  Box: "Optimize" / "AdamW · cosine"
  Box: "Checkpoint" / "Every 1K steps"

[SECTION 3 — "Evaluate" — yellow tint background #F5F2EA]
- Header: "EVALUATE" in #EBCB8B
- Three white floating boxes:
  Box: "Benchmark" / "MMLU · HumanEval"
  Box: "Analyze" / "Scaling curves"
  Box: "Report" / "Camera-ready"

ARROWS:
1. "Tokenize" → "Model": thin gray #6B7280, vertical, label "feeds"
2. "Checkpoint" → "Benchmark": thin gray, vertical, label "evaluate"
3. "Analyze" → "Report": thin gray, horizontal, label "publish"

CONSTRAINTS:
- ZERO decoration — no icons, no illustrations
- NO visible box borders — shadow only
- Generous whitespace between all elements
- NO figure numbers, NO captions, NO watermarks
- Background: pure white #FFFFFF
- All labels EXACTLY as written
- Publication quality for ICML 2026
```

## 多次尝试评估标准

按以下 5 个维度对每次生成结果打分（1-5 分）：

| 维度 | 检查要点 | 权重 |
|-----------|---------------|--------|
| **风格还原度** | 是否符合所要求的视觉风格？（如手绘感、简洁简约） | 30% |
| **文字准确性** | 所有标签拼写是否正确，有无幽灵文字？ | 25% |
| **布局还原度** | 空间排布是否与提示词一致？ | 20% |
| **色彩准确性** | 颜色是否与十六进制色值一致？整体是否统一？ | 15% |
| **连接准确性** | 所有箭头是否存在，走向和标签是否正确？ | 10% |

**风格还原度失败时**：加强风格描述块，增加更多感官性描述。补充："The overall aesthetic should resemble [specific reference]."

**文字失败时**：添加 `CRITICAL: The word "[exact word]" must appear EXACTLY. Do not abbreviate, do not change capitalization.`

**布局失败时**：添加明确的坐标或网格参考。"Box A is at position (left: 10%, top: 20%)."

## TikZ 替代方案（适用于原生 LaTeX 图表）

当图表足够简单、可以获得确定性输出时使用：

```latex
\begin{tikzpicture}[
    box/.style={draw=#1, fill=#1!8, rounded corners=6pt, minimum width=2.8cm,
                minimum height=1cm, font=\small\sffamily, line width=0.8pt},
    lbl/.style={font=\scriptsize\sffamily\itshape, text=#1},
    arr/.style={-{Stealth[length=5pt]}, line width=0.8pt, color=#1},
]
    \node[box=teal]   (plan) at (0,0)    {Planner};
    \node[box=orange]  (exec) at (4,0)    {Executor};
    \node[box=olive]   (veri) at (8,0)    {Verifier};

    \draw[arr=gray]  (plan) -- (exec) node[midway, above, lbl=gray] {task plan};
    \draw[arr=gray]  (exec) -- (veri) node[midway, above, lbl=gray] {results};
    \draw[arr=red!60, dashed] (veri) to[bend right=30]
        node[midway, below, lbl=red!60] {revise} (plan);
\end{tikzpicture}
```

## Mermaid 快速原型验证

在投入 Gemini 生成之前，先用 Mermaid 勾勒逻辑流程：

```mermaid
graph LR
    A[Observe] --> B[Hypothesize]
    B --> C[Verify]
    C -.->|refine| A
```

确认结构正确后，再编写完整的 Gemini 提示词。
