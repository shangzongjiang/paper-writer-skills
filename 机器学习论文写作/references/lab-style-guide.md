# 实验室写作风格指南

基于三篇代表作提炼：TimePMG（匿名投稿）、TimeMRA（ICML 2026）、MSH-LLM（ICLR 2025）。
写作时严格参照以下模式，保持实验室风格一致性。

---

## 1. 摘要（Abstract）

**固定结构（五步走）：**

```
[1] 领域定位句：{Task} plays a pivotal/critical role in data-driven decision-making
    across various {domains}.

[2] 现有方法句：Recently, {approach} has achieved promising results in {task}.
    However, existing {methods} struggle to {limitation} due to {cause1}
    and {cause2}.

[3] 方案提出句：To address this, we propose \textbf{ModelName}, a {description}
    via {core mechanism}.

[4] 模块描述句：Specifically, a {Module1} ({ABBR1}) module is designed to {function1}.
    Then, a {Module2} ({ABBR2}) mechanism is designed to {function2}.
    Finally, {Module3} is designed to {function3}.

[5] 实验总结句：Experimental results on {N} real-world datasets across {K} different
    applications demonstrate that {ModelName} achieves state-of-the-art performance.
```

**命名规范：** 模型缩写用 `$\textbf{\underline{X}}$` 格式逐字母加粗下划线展开。

---

## 2. 引言（Introduction）

**第一段：领域重要性**

```
{Task} constitutes/plays a critical component of data-driven decision making,
with wide-ranging implications across critical domains, e.g., {domain1} \cite{},
{domain2} \cite{}, and {domain3} \cite{}.
```

**第二段：方法演进（固定叙述链）**

```
Traditional methods, e.g., {method1} and {method2}, have been proposed to
{capability}, but they fail to {limitation}. To address this, deep learning-based
methods, e.g., {RNN} \cite{}, {Transformer} \cite{}, have been proposed.
Nevertheless, {remaining gap}.
```

**第三段：LLM 引入 + 问题定位**

```
Recently, large language models (LLMs) have been used for {task}. However,
they are not only limited by {bottleneck1} but more importantly, face the
{issue} problem, where {explanation}.
```

**第四段：本文方案（一句话论题）**

```
To address this, we propose {ModelName}, which {core idea} to achieve {goal}.
```

**贡献列举格式（统一用 itemize）：**

```latex
The contributions of this paper are summarized as follows:
\begin{itemize}
\item{We introduce/propose a {component} that {mechanism}, which can {benefit}
      while {addressing limitation}.}
\item{We design a {module} to {function}, which goes beyond {prior approach}
      and obtains {improvement}.}
\item{We conduct experiments on {N} real-world datasets across {K} different
      applications. The experimental results demonstrate that {ModelName}
      achieves state-of-the-art (SOTA) performance.}
\end{itemize}
```

**规律：** 前 N-1 条写技术贡献，最后一条固定写实验结论。每条结构：We [动词] [组件] that/to [机制], which [效果]。

---

## 3. 方法（Methodology）

**框架总览段（必须有，紧接节标题）：**

```
Figure \ref{fig} illustrates the overall framework of {ModelName}, which
consists of {N} main components: (1) A {Module1} ({ABBR1}) module to {role1};
(2) A {Module2} ({ABBR2}) module to {role2}; (3) A {Module3} ({ABBR3})
module to {role3}.
```

**子模块小节格式：**

```latex
\subsection{{Module Name} ({ABBR}) Module}

To {goal}, the {ABBR} module first {step1}, and then {step2}.

\textbf{{Sub-component 1}.} {description starting with "Given input X, we first...
Then... Finally..."}

\textbf{{Sub-component 2}.} {description}
```

**关键动词规范：**
- 模块功能：`is designed to`（不用 is used to / aims to）
- 模块引入：`is introduced to`（引出新机制时）
- 步骤衔接：`Specifically → Then → Finally / In addition`（三步固定顺序）

**数学公式衔接：**

```
which can be formulated as follows:
\begin{equation}
  ...
\end{equation}
where {variable} denotes/represents {meaning}.
```

---

## 4. 实验（Experiments）

**实验设置段：**

```
We evaluate {ModelName} on {N} real-world datasets across {K} different
applications, including {app1}, {app2}, etc.
```

**结果描述句式：**

```
{ModelName} achieves state-of-the-art (SOTA) performance on {dataset},
outperforming {baseline} by {X}% in terms of {metric}.
```

**消融实验句式：**

```
To justify the effectiveness of {component}, we conduct ablation studies
by removing {component} from {ModelName}. The results demonstrate that
{component} contributes significantly to overall performance.
```

---

## 5. 结论（Conclusion）

结论与摘要高度镜像，按以下三步压缩：

```
[1] 本文提出句：This paper proposed {ModelName}, the first/a {description}
    via {mechanism}.

[2] 模块总结句：Specifically, {Module1} is designed to {function1} and
    {Module2} is used to {function2}.

[3] 实验验证句：Experiment results and qualitative analysis justify the
    effectiveness of {ModelName}.
```

---

## 6. 高频词汇与表达规范

| 场景 | 推荐表达 | 避免 |
|------|----------|------|
| 提出方案 | `To address this, we propose` | `In this paper, we present` |
| 模块功能 | `is designed to` | `aims to / tries to` |
| 实验验证 | `justify the effectiveness` | `prove / show the results` |
| 性能声明 | `achieves state-of-the-art (SOTA) performance` | `performs best` |
| 问题定位 | `However, existing methods... due to X and Y` | `Unfortunately` |
| 模块引入 | `a {Module} ({ABBR}) module is designed to` | 无缩写直接描述 |
| 步骤衔接 | `Specifically... Then... Finally...` | `First... Second... Third...` |
| 解释变量 | `where {var} denotes/represents {meaning}` | `here {var} is` |
| 贡献动词 | `introduce / propose / design / conduct` | `present / show / try` |

---

## 7. 格式细节

- **模型名加粗**：正文中首次出现用 `\textbf{ModelName}`
- **缩写展开**：`$\textbf{\underline{T}}$ime$\textbf{\underline{M}}$RA` 格式
- **模块命名**：全称 + 括号缩写，结尾加 Module/Mechanism，如 `Scale-Aware Prompt Generation (SAPG) Module`
- **子组件标题**：`\textbf{Sub-component Name.}` 加句点，同行接描述
- **引言引用密度**：每个应用领域后跟 2-3 个 `\cite{}`，体现覆盖广度
