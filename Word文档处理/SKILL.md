---
name: Word文档处理
description: 创建、读取、编辑 Word（.docx）文件。适用于报告、备忘录、信函或任何格式化的 Word 文档输出。
license: Proprietary. LICENSE.txt has complete terms
---

# DOCX 文件的创建、编辑与分析

## 概述

.docx 文件是一个包含 XML 文件的 ZIP 压缩包。

## 快速参考

| 任务 | 方法 |
|------|----------|
| 读取/分析内容 | 使用 `pandoc` 或解包查看原始 XML |
| 创建新文档 | 使用 `docx-js` —— 参见下方"创建新文档" |
| 编辑已有文档 | 解包 → 编辑 XML → 重新打包 —— 参见下方"编辑已有文档" |

### 将 .doc 转换为 .docx

旧版 `.doc` 文件在编辑前必须先转换：

```bash
python scripts/office/soffice.py --headless --convert-to docx document.doc
```

### 读取内容

```bash
# 提取文本并保留修订记录
pandoc --track-changes=all document.docx -o output.md

# 访问原始 XML
python scripts/office/unpack.py document.docx unpacked/
```

### 转换为图片

```bash
python scripts/office/soffice.py --headless --convert-to pdf document.docx
pdftoppm -jpeg -r 150 document.pdf page
```

### 接受修订记录

生成一份接受全部修订的干净文档（需要 LibreOffice）：

```bash
python scripts/accept_changes.py input.docx output.docx
```

---

## 创建新文档

使用 JavaScript 生成 .docx 文件，然后验证。安装：`npm install -g docx`

### 初始设置
```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
        Header, Footer, AlignmentType, PageOrientation, LevelFormat, ExternalHyperlink,
        InternalHyperlink, Bookmark, FootnoteReferenceRun, PositionalTab,
        PositionalTabAlignment, PositionalTabRelativeTo, PositionalTabLeader,
        TabStopType, TabStopPosition, Column, SectionType,
        TableOfContents, HeadingLevel, BorderStyle, WidthType, ShadingType,
        VerticalAlign, PageNumber, PageBreak } = require('docx');

const doc = new Document({ sections: [{ children: [/* 内容 */] }] });
Packer.toBuffer(doc).then(buffer => fs.writeFileSync("doc.docx", buffer));
```

### 验证
创建文件后请进行验证。如果验证失败，解包、修复 XML，然后重新打包。
```bash
python scripts/office/validate.py doc.docx
```

### 页面尺寸

```javascript
// 重要：docx-js 默认使用 A4 纸，而非美国信纸
// 始终明确设置页面尺寸以确保结果一致
sections: [{
  properties: {
    page: {
      size: {
        width: 12240,   // 8.5 英寸（DXA 单位）
        height: 15840   // 11 英寸（DXA 单位）
      },
      margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } // 1 英寸页边距
    }
  },
  children: [/* 内容 */]
}]
```

**常用页面尺寸（DXA 单位，1440 DXA = 1 英寸）：**

| 纸张 | 宽度 | 高度 | 内容宽度（1 英寸页边距） |
|-------|-------|--------|---------------------------|
| 美国信纸 | 12,240 | 15,840 | 9,360 |
| A4（默认） | 11,906 | 16,838 | 9,026 |

**横向方向：** docx-js 会在内部交换宽高，因此传入竖向尺寸并让它自行处理交换：
```javascript
size: {
  width: 12240,   // 传入短边作为宽度
  height: 15840,  // 传入长边作为高度
  orientation: PageOrientation.LANDSCAPE  // docx-js 会在 XML 中交换
},
// 内容宽度 = 15840 - 左边距 - 右边距（使用长边）
```

### 样式（覆盖内置标题样式）

使用 Arial 作为默认字体（通用兼容）。标题保持黑色以便于阅读。

```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } }, // 默认 12pt
    paragraphStyles: [
      // 重要：使用精确的 ID 来覆盖内置样式
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } }, // TOC 需要 outlineLevel
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
    ]
  },
  sections: [{
    children: [
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Title")] }),
    ]
  }]
});
```

### 列表（禁止使用 Unicode 项目符号）

```javascript
// ❌ 错误——永远不要手动插入项目符号字符
new Paragraph({ children: [new TextRun("• Item")] })  // 错误
new Paragraph({ children: [new TextRun("• Item")] })  // 错误

// ✅ 正确——使用带 LevelFormat.BULLET 的编号配置
const doc = new Document({
  numbering: {
    config: [
      { reference: "bullets",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "numbers",
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ]
  },
  sections: [{
    children: [
      new Paragraph({ numbering: { reference: "bullets", level: 0 },
        children: [new TextRun("Bullet item")] }),
      new Paragraph({ numbering: { reference: "numbers", level: 0 },
        children: [new TextRun("Numbered item")] }),
    ]
  }]
});

// ⚠️ 每个 reference 创建独立的编号
// 相同 reference = 连续（1,2,3 接 4,5,6）
// 不同 reference = 重新开始（1,2,3 接 1,2,3）
```

### 表格

**重要：表格需要双重宽度设置** —— 同时在表格上设置 `columnWidths`，在每个单元格上设置 `width`。缺少其中任何一个，表格在某些平台上会渲染错误。

```javascript
// 重要：始终设置表格宽度以确保一致渲染
// 重要：使用 ShadingType.CLEAR（而非 SOLID）以防止黑色背景
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };

new Table({
  width: { size: 9360, type: WidthType.DXA }, // 始终使用 DXA（百分比在 Google Docs 中失效）
  columnWidths: [4680, 4680], // 必须与表格宽度之和相等（DXA：1440 = 1 英寸）
  rows: [
    new TableRow({
      children: [
        new TableCell({
          borders,
          width: { size: 4680, type: WidthType.DXA }, // 每个单元格也要设置
          shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, // CLEAR 而非 SOLID
          margins: { top: 80, bottom: 80, left: 120, right: 120 }, // 单元格内边距（不计入宽度）
          children: [new Paragraph({ children: [new TextRun("Cell")] })]
        })
      ]
    })
  ]
})
```

**表格宽度计算：**

始终使用 `WidthType.DXA` —— `WidthType.PERCENTAGE` 在 Google Docs 中会失效。

```javascript
// 表格宽度 = columnWidths 之和 = 内容宽度
// 美国信纸 1 英寸页边距：12240 - 2880 = 9360 DXA
width: { size: 9360, type: WidthType.DXA },
columnWidths: [7000, 2360]  // 必须与表格宽度之和相等
```

**宽度规则：**
- **始终使用 `WidthType.DXA`** —— 绝不使用 `WidthType.PERCENTAGE`（与 Google Docs 不兼容）
- 表格宽度必须等于 `columnWidths` 的总和
- 单元格 `width` 必须与对应的 `columnWidth` 一致
- 单元格 `margins` 是内部填充 —— 会减小内容区域，不增加单元格宽度
- 全宽表格：使用内容宽度（页面宽度减去左右页边距）

### 图片

```javascript
// 重要：type 参数是必填项
new Paragraph({
  children: [new ImageRun({
    type: "png", // 必填：png、jpg、jpeg、gif、bmp、svg
    data: fs.readFileSync("image.png"),
    transformation: { width: 200, height: 150 },
    altText: { title: "Title", description: "Desc", name: "Name" } // 三个字段均为必填
  })]
})
```

### 分页符

```javascript
// 重要：PageBreak 必须放在 Paragraph 内
new Paragraph({ children: [new PageBreak()] })

// 或使用 pageBreakBefore
new Paragraph({ pageBreakBefore: true, children: [new TextRun("New page")] })
```

### 超链接

```javascript
// 外部链接
new Paragraph({
  children: [new ExternalHyperlink({
    children: [new TextRun({ text: "Click here", style: "Hyperlink" })],
    link: "https://example.com",
  })]
})

// 内部链接（书签 + 引用）
// 1. 在目标位置创建书签
new Paragraph({ heading: HeadingLevel.HEADING_1, children: [
  new Bookmark({ id: "chapter1", children: [new TextRun("Chapter 1")] }),
]})
// 2. 链接到该书签
new Paragraph({ children: [new InternalHyperlink({
  children: [new TextRun({ text: "See Chapter 1", style: "Hyperlink" })],
  anchor: "chapter1",
})]})
```

### 脚注

```javascript
const doc = new Document({
  footnotes: {
    1: { children: [new Paragraph("Source: Annual Report 2024")] },
    2: { children: [new Paragraph("See appendix for methodology")] },
  },
  sections: [{
    children: [new Paragraph({
      children: [
        new TextRun("Revenue grew 15%"),
        new FootnoteReferenceRun(1),
        new TextRun(" using adjusted metrics"),
        new FootnoteReferenceRun(2),
      ],
    })]
  }]
});
```

### 制表位

```javascript
// 在同一行右对齐文本（如标题对面的日期）
new Paragraph({
  children: [
    new TextRun("Company Name"),
    new TextRun("\tJanuary 2025"),
  ],
  tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
})

// 点状前导符（如目录样式）
new Paragraph({
  children: [
    new TextRun("Introduction"),
    new TextRun({ children: [
      new PositionalTab({
        alignment: PositionalTabAlignment.RIGHT,
        relativeTo: PositionalTabRelativeTo.MARGIN,
        leader: PositionalTabLeader.DOT,
      }),
      "3",
    ]}),
  ],
})
```

### 多栏布局

```javascript
// 等宽分栏
sections: [{
  properties: {
    column: {
      count: 2,          // 栏数
      space: 720,        // 栏间距（DXA，720 = 0.5 英寸）
      equalWidth: true,
      separate: true,    // 栏间竖线
    },
  },
  children: [/* 内容自然流入各栏 */]
}]

// 自定义宽度分栏（equalWidth 必须为 false）
sections: [{
  properties: {
    column: {
      equalWidth: false,
      children: [
        new Column({ width: 5400, space: 720 }),
        new Column({ width: 3240 }),
      ],
    },
  },
  children: [/* 内容 */]
}]
```

使用 `type: SectionType.NEXT_COLUMN` 的新节来强制换栏。

### 目录

```javascript
// 重要：标题必须只使用 HeadingLevel —— 不能使用自定义样式
new TableOfContents("Table of Contents", { hyperlink: true, headingStyleRange: "1-3" })
```

### 页眉/页脚

```javascript
sections: [{
  properties: {
    page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } // 1440 = 1 英寸
  },
  headers: {
    default: new Header({ children: [new Paragraph({ children: [new TextRun("Header")] })] })
  },
  footers: {
    default: new Footer({ children: [new Paragraph({
      children: [new TextRun("Page "), new TextRun({ children: [PageNumber.CURRENT] })]
    })] })
  },
  children: [/* 内容 */]
}]
```

### docx-js 关键规则

- **明确设置页面尺寸** —— docx-js 默认 A4；美国文档使用信纸（12240 x 15840 DXA）
- **横向：传入竖向尺寸** —— docx-js 内部会交换宽高；将短边传为 `width`，长边传为 `height`，并设置 `orientation: PageOrientation.LANDSCAPE`
- **禁止使用 `\n`** —— 改用独立的 Paragraph 元素
- **禁止使用 Unicode 项目符号** —— 使用带编号配置的 `LevelFormat.BULLET`
- **PageBreak 必须在 Paragraph 内** —— 独立使用会产生无效 XML
- **ImageRun 必须指定 `type`** —— 始终指定 png/jpg 等类型
- **始终用 DXA 设置表格 `width`** —— 绝不使用 `WidthType.PERCENTAGE`（在 Google Docs 中失效）
- **表格需要双重宽度** —— `columnWidths` 数组和单元格 `width` 都需要设置且必须一致
- **表格宽度 = columnWidths 之和** —— DXA 模式下必须精确相加
- **始终添加单元格内边距** —— 使用 `margins: { top: 80, bottom: 80, left: 120, right: 120 }` 确保可读性
- **使用 `ShadingType.CLEAR`** —— 表格底纹绝不使用 SOLID
- **禁止用表格作为分隔线/水平线** —— 单元格有最小高度，会渲染成空框（包括页眉/页脚中）；改用段落的 `border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "2E75B6", space: 1 } }`。双栏页脚请使用制表位（见制表位章节），而非表格
- **目录只允许使用 HeadingLevel** —— 标题段落不能使用自定义样式
- **覆盖内置样式** —— 使用精确 ID："Heading1"、"Heading2" 等
- **必须包含 `outlineLevel`** —— TOC 所需（H1 为 0，H2 为 1，依此类推）

---

## 编辑已有文档

**请按顺序执行以下全部 3 个步骤。**

### 步骤 1：解包
```bash
python scripts/office/unpack.py document.docx unpacked/
```
提取 XML，美化格式，合并相邻的 run，并将弯引号转换为 XML 实体（如 `&#x201C;` 等），以确保它们在编辑后仍然有效。使用 `--merge-runs false` 可跳过 run 合并。

### 步骤 2：编辑 XML

编辑 `unpacked/word/` 中的文件。XML 参考模式见下方。

**使用"Claude"作为作者名**用于修订记录和批注，除非用户明确要求使用其他名称。

**直接使用 Edit 工具进行字符串替换，不要编写 Python 脚本。** 脚本会引入不必要的复杂性。Edit 工具能清晰显示被替换的内容。

**重要：新内容请使用弯引号。** 添加含撇号或引号的文本时，使用 XML 实体生成弯引号：
```xml
<!-- 使用这些实体实现专业排版 -->
<w:t>Here&#x2019;s a quote: &#x201C;Hello&#x201D;</w:t>
```
| 实体 | 字符 |
|--------|-----------|
| `&#x2018;` | ' （左单引号） |
| `&#x2019;` | ' （右单引号/撇号） |
| `&#x201C;` | " （左双引号） |
| `&#x201D;` | " （右双引号） |

**添加批注：** 使用 `comment.py` 处理多个 XML 文件中的样板内容（文本必须预先转义为 XML）：
```bash
python scripts/comment.py unpacked/ 0 "Comment text with &amp; and &#x2019;"
python scripts/comment.py unpacked/ 1 "Reply text" --parent 0  # 回复批注 0
python scripts/comment.py unpacked/ 0 "Text" --author "Custom Author"  # 自定义作者名
```
然后在 document.xml 中添加标记（见下方 XML 参考中的"批注"部分）。

### 步骤 3：打包
```bash
python scripts/office/pack.py unpacked/ output.docx --original document.docx
```
自动修复、压缩 XML 并创建 DOCX。使用 `--validate false` 跳过验证。

**自动修复可以处理：**
- `durableId` >= 0x7FFFFFFF（重新生成有效 ID）
- `<w:t>` 中含空白字符但缺少 `xml:space="preserve"` 的情况

**自动修复无法处理：**
- 格式错误的 XML、无效的元素嵌套、缺失的关系声明、Schema 违规

### 常见陷阱

- **替换整个 `<w:r>` 元素**：添加修订记录时，将整个 `<w:r>...</w:r>` 块替换为并列的 `<w:del>...<w:ins>...`。不要在 run 内部注入修订标签。
- **保留 `<w:rPr>` 格式**：将原始 run 的 `<w:rPr>` 块复制到修订 run 中，以维持粗体、字号等格式。

---

## XML 参考

### Schema 合规性

- **`<w:pPr>` 中的元素顺序**：`<w:pStyle>`、`<w:numPr>`、`<w:spacing>`、`<w:ind>`、`<w:jc>`，`<w:rPr>` 最后
- **空白字符**：对含前导/后缀空格的 `<w:t>` 添加 `xml:space="preserve"`
- **RSID**：必须为 8 位十六进制（如 `00AB1234`）

### 修订记录

**插入：**
```xml
<w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:t>inserted text</w:t></w:r>
</w:ins>
```

**删除：**
```xml
<w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>
```

**在 `<w:del>` 内**：使用 `<w:delText>` 而非 `<w:t>`，使用 `<w:delInstrText>` 而非 `<w:instrText>`。

**最小化修改** —— 只标记发生变化的部分：
```xml
<!-- 将 "30 days" 改为 "60 days" -->
<w:r><w:t>The term is </w:t></w:r>
<w:del w:id="1" w:author="Claude" w:date="...">
  <w:r><w:delText>30</w:delText></w:r>
</w:del>
<w:ins w:id="2" w:author="Claude" w:date="...">
  <w:r><w:t>60</w:t></w:r>
</w:ins>
<w:r><w:t> days.</w:t></w:r>
```

**删除整个段落/列表项** —— 删除某段落的全部内容时，还需将段落标记也标为已删除，使其与下一段落合并。在 `<w:pPr><w:rPr>` 内添加 `<w:del/>`：
```xml
<w:p>
  <w:pPr>
    <w:numPr>...</w:numPr>  <!-- 如有列表编号 -->
    <w:rPr>
      <w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z"/>
    </w:rPr>
  </w:pPr>
  <w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
    <w:r><w:delText>Entire paragraph content being deleted...</w:delText></w:r>
  </w:del>
</w:p>
```
若未在 `<w:pPr><w:rPr>` 中添加 `<w:del/>`，接受修订后会留下空段落/列表项。

**拒绝他人的插入** —— 在其插入内嵌套删除：
```xml
<w:ins w:author="Jane" w:id="5">
  <w:del w:author="Claude" w:id="10">
    <w:r><w:delText>their inserted text</w:delText></w:r>
  </w:del>
</w:ins>
```

**恢复他人的删除** —— 在其删除后添加插入（不修改其删除标记）：
```xml
<w:del w:author="Jane" w:id="5">
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>
<w:ins w:author="Claude" w:id="10">
  <w:r><w:t>deleted text</w:t></w:r>
</w:ins>
```

### 批注

运行 `comment.py` 后（见步骤 2），在 document.xml 中添加标记。回复请使用 `--parent` 标志，并将标记嵌套在父批注内。

**重要：`<w:commentRangeStart>` 和 `<w:commentRangeEnd>` 是 `<w:r>` 的兄弟元素，绝不能放在 `<w:r>` 内。**

```xml
<!-- 批注标记是 w:p 的直接子元素，绝不放在 w:r 内 -->
<w:commentRangeStart w:id="0"/>
<w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted</w:delText></w:r>
</w:del>
<w:r><w:t> more text</w:t></w:r>
<w:commentRangeEnd w:id="0"/>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>

<!-- 批注 0 内嵌套回复 1 -->
<w:commentRangeStart w:id="0"/>
  <w:commentRangeStart w:id="1"/>
  <w:r><w:t>text</w:t></w:r>
  <w:commentRangeEnd w:id="1"/>
<w:commentRangeEnd w:id="0"/>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="1"/></w:r>
```

### 图片

1. 将图片文件添加到 `word/media/`
2. 在 `word/_rels/document.xml.rels` 中添加关系声明：
```xml
<Relationship Id="rId5" Type=".../image" Target="media/image1.png"/>
```
3. 在 `[Content_Types].xml` 中添加内容类型：
```xml
<Default Extension="png" ContentType="image/png"/>
```
4. 在 document.xml 中引用：
```xml
<w:drawing>
  <wp:inline>
    <wp:extent cx="914400" cy="914400"/>  <!-- EMU：914400 = 1 英寸 -->
    <a:graphic>
      <a:graphicData uri=".../picture">
        <pic:pic>
          <pic:blipFill><a:blip r:embed="rId5"/></pic:blipFill>
        </pic:pic>
      </a:graphicData>
    </a:graphic>
  </wp:inline>
</w:drawing>
```

---

## 依赖项

- **pandoc**：文本提取
- **docx**：`npm install -g docx`（新文档）
- **LibreOffice**：PDF 转换（通过 `scripts/office/soffice.py` 自动配置沙箱环境）
- **Poppler**：`pdftoppm` 用于图片转换

---
如未收到具体问题，直接询问："你在使用 docx 时想构建什么或调试什么？请分享你的代码、配置或错误信息。"
