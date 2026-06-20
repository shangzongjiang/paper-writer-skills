---
name: Excel表格处理
description: 读取、写入或转换电子表格。适用于输入/输出为 .xlsx、.xlsm、.csv 或 .tsv 文件的场景。
license: Proprietary. LICENSE.txt has complete terms
---

# 输出要求规范

## 所有 Excel 文件

### 专业字体
- 除非用户另有指示，所有交付物均应使用统一的专业字体（如 Arial、Times New Roman）

### 零公式错误
- 每个 Excel 模型交付时必须确保零公式错误（#REF!、#DIV/0!、#VALUE!、#N/A、#NAME?）

### 保留现有模板（更新模板时）
- 修改文件时，须仔细研究并严格匹配现有格式、风格和约定
- 不得对已有固定风格的文件强行套用标准化格式
- 现有模板约定始终优先于本指南

## 财务模型

### 颜色编码标准
除非用户或现有模板另有规定

#### 行业标准颜色约定
- **蓝色文字（RGB: 0,0,255）**：硬编码输入值及用户会在情景分析中调整的数字
- **黑色文字（RGB: 0,0,0）**：所有公式和计算结果
- **绿色文字（RGB: 0,128,0）**：从同一工作簿其他工作表引用的链接数据
- **红色文字（RGB: 255,0,0）**：引用其他文件的外部链接
- **黄色背景（RGB: 255,255,0）**：需要关注的关键假设或待填写的单元格

### 数字格式标准

#### 必须遵守的格式规则
- **年份**：格式化为文本字符串（如 "2024" 而非 "2,024"）
- **货币**：使用 $#,##0 格式；标题中务必注明单位（如 "Revenue ($mm)"）
- **零值**：用数字格式将所有零值显示为 "-"，包括百分比（如 "$#,##0;($#,##0);-"）
- **百分比**：默认使用 0.0% 格式（保留一位小数）
- **倍数**：估值倍数（EV/EBITDA、P/E）格式化为 0.0x
- **负数**：使用括号表示 (123)，而非负号 -123

### 公式构建规则

#### 假设值放置
- 将所有假设值（增长率、利润率、倍数等）放在独立的假设单元格中
- 公式中使用单元格引用，而非直接写入数值
- 示例：使用 =B5*(1+$B$6) 而非 =B5*1.05

#### 公式错误预防
- 验证所有单元格引用的正确性
- 检查范围内的差一错误
- 确保所有预测期间的公式保持一致
- 用边界情况测试（零值、负数）
- 确认不存在意外的循环引用

#### 硬编码值的文档要求
- 在单元格内或旁边添加注释（位于表格末尾时）。格式："Source: [系统/文档], [日期], [具体引用], [URL（如适用）]"
- 示例：
  - "Source: Company 10-K, FY2024, Page 45, Revenue Note, [SEC EDGAR URL]"
  - "Source: Company 10-Q, Q2 2025, Exhibit 99.1, [SEC EDGAR URL]"
  - "Source: Bloomberg Terminal, 8/15/2025, AAPL US Equity"
  - "Source: FactSet, 8/20/2025, Consensus Estimates Screen"

# XLSX 文件的创建、编辑与分析

## 概述

用户可能要求你创建、编辑或分析 .xlsx 文件内容。针对不同任务，有不同的工具和工作流可供选择。

## 重要要求

**公式重算需要 LibreOffice**：可假设 LibreOffice 已安装，用于通过 `scripts/recalc.py` 脚本重算公式值。该脚本首次运行时会自动配置 LibreOffice，包括在 Unix socket 受限的沙箱环境中（由 `scripts/office/soffice.py` 处理）。

## 读取与分析数据

### 使用 pandas 进行数据分析
数据分析、可视化及基本操作，推荐使用 **pandas**，它提供强大的数据处理能力：

```python
import pandas as pd

# 读取 Excel
df = pd.read_excel('file.xlsx')  # 默认读取第一个工作表
all_sheets = pd.read_excel('file.xlsx', sheet_name=None)  # 以字典形式读取所有工作表

# 分析
df.head()      # 预览数据
df.info()      # 列信息
df.describe()  # 统计摘要

# 写入 Excel
df.to_excel('output.xlsx', index=False)
```

## Excel 文件工作流

## 关键原则：使用公式而非硬编码值

**始终使用 Excel 公式，而非在 Python 中计算后将结果硬编码。** 这样可确保电子表格保持动态，便于后续更新。

### ❌ 错误做法 - 将计算结果硬编码
```python
# 错误：在 Python 中计算后硬编码结果
total = df['Sales'].sum()
sheet['B10'] = total  # 硬编码了 5000

# 错误：在 Python 中计算增长率
growth = (df.iloc[-1]['Revenue'] - df.iloc[0]['Revenue']) / df.iloc[0]['Revenue']
sheet['C5'] = growth  # 硬编码了 0.15

# 错误：用 Python 计算平均值
avg = sum(values) / len(values)
sheet['D20'] = avg  # 硬编码了 42.5
```

### ✅ 正确做法 - 使用 Excel 公式
```python
# 正确：让 Excel 计算求和
sheet['B10'] = '=SUM(B2:B9)'

# 正确：用 Excel 公式计算增长率
sheet['C5'] = '=(C4-C2)/C2'

# 正确：用 Excel 函数计算平均值
sheet['D20'] = '=AVERAGE(D2:D19)'
```

这一原则适用于所有计算——合计、百分比、比率、差值等。电子表格应能在源数据变更时自动重算。

## 常用工作流
1. **选择工具**：数据处理用 pandas，公式/格式处理用 openpyxl
2. **创建/加载**：新建工作簿或加载现有文件
3. **修改**：添加/编辑数据、公式和格式
4. **保存**：写入文件
5. **重算公式（使用公式时为必须步骤）**：使用 scripts/recalc.py 脚本
   ```bash
   python scripts/recalc.py output.xlsx
   ```
6. **验证并修复错误**：
   - 脚本以 JSON 格式返回错误详情
   - 若 `status` 为 `errors_found`，查看 `error_summary` 了解具体错误类型和位置
   - 修复识别到的错误后再次重算
   - 常见错误类型：
     - `#REF!`：无效的单元格引用
     - `#DIV/0!`：除以零
     - `#VALUE!`：公式中数据类型错误
     - `#NAME?`：无法识别的公式名称

### 新建 Excel 文件

```python
# 使用 openpyxl 处理公式和格式
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active

# 添加数据
sheet['A1'] = 'Hello'
sheet['B1'] = 'World'
sheet.append(['Row', 'of', 'data'])

# 添加公式
sheet['B2'] = '=SUM(A1:A10)'

# 格式设置
sheet['A1'].font = Font(bold=True, color='FF0000')
sheet['A1'].fill = PatternFill('solid', start_color='FFFF00')
sheet['A1'].alignment = Alignment(horizontal='center')

# 列宽
sheet.column_dimensions['A'].width = 20

wb.save('output.xlsx')
```

### 编辑现有 Excel 文件

```python
# 使用 openpyxl 保留公式和格式
from openpyxl import load_workbook

# 加载现有文件
wb = load_workbook('existing.xlsx')
sheet = wb.active  # 或 wb['SheetName'] 指定工作表

# 操作多个工作表
for sheet_name in wb.sheetnames:
    sheet = wb[sheet_name]
    print(f"Sheet: {sheet_name}")

# 修改单元格
sheet['A1'] = 'New Value'
sheet.insert_rows(2)  # 在第 2 行插入一行
sheet.delete_cols(3)  # 删除第 3 列

# 新建工作表
new_sheet = wb.create_sheet('NewSheet')
new_sheet['A1'] = 'Data'

wb.save('modified.xlsx')
```

## 重算公式

openpyxl 创建或修改的 Excel 文件，其公式以字符串形式存储，不含计算值。使用 `scripts/recalc.py` 脚本重算公式：

```bash
python scripts/recalc.py <excel_file> [timeout_seconds]
```

示例：
```bash
python scripts/recalc.py output.xlsx 30
```

该脚本的功能：
- 首次运行时自动配置 LibreOffice 宏
- 重算所有工作表中的所有公式
- 扫描所有单元格的 Excel 错误（#REF!、#DIV/0! 等）
- 以 JSON 格式返回详细的错误位置和数量
- 支持 Linux 和 macOS

## 公式验证清单

确保公式正确运行的快速检查项：

### 基本验证
- [ ] **测试 2–3 个示例引用**：在构建完整模型前，验证它们是否引用了正确的值
- [ ] **列映射**：确认 Excel 列号对应正确（如第 64 列是 BL 而非 BK）
- [ ] **行偏移**：注意 Excel 行从 1 开始（DataFrame 第 5 行 = Excel 第 6 行）

### 常见陷阱
- [ ] **NaN 处理**：用 `pd.notna()` 检查空值
- [ ] **靠右侧的列**：财年数据通常在第 50+ 列
- [ ] **多个匹配项**：搜索所有匹配，而非仅第一个
- [ ] **除以零**：在公式中使用 `/` 前先检查分母（#DIV/0!）
- [ ] **错误引用**：验证所有单元格引用指向预期单元格（#REF!）
- [ ] **跨表引用**：使用正确格式（Sheet1!A1）链接工作表

### 公式测试策略
- [ ] **从小处开始**：在 2–3 个单元格测试公式后再大范围应用
- [ ] **验证依赖项**：检查公式引用的所有单元格是否存在
- [ ] **测试边界情况**：包含零值、负值和极大值

### 解读 scripts/recalc.py 输出

脚本返回包含错误详情的 JSON：
```json
{
  "status": "success",           // 或 "errors_found"
  "total_errors": 0,              // 总错误数
  "total_formulas": 42,           // 文件中的公式数
  "error_summary": {              // 仅在发现错误时出现
    "#REF!": {
      "count": 2,
      "locations": ["Sheet1!B5", "Sheet1!C10"]
    }
  }
}
```

## 最佳实践

### 库的选择
- **pandas**：最适合数据分析、批量操作和简单数据导出
- **openpyxl**：最适合复杂格式设置、公式及 Excel 专有功能

### 使用 openpyxl 的注意事项
- 单元格索引从 1 开始（row=1, column=1 对应 A1 单元格）
- 读取计算值时使用 `data_only=True`：`load_workbook('file.xlsx', data_only=True)`
- **警告**：使用 `data_only=True` 打开后再保存，公式会被值永久替换并丢失
- 大文件读取用 `read_only=True`，写入用 `write_only=True`
- 公式被保留但不计算——使用 scripts/recalc.py 更新值

### 使用 pandas 的注意事项
- 指定数据类型以避免推断问题：`pd.read_excel('file.xlsx', dtype={'id': str})`
- 大文件只读取特定列：`pd.read_excel('file.xlsx', usecols=['A', 'C', 'E'])`
- 正确处理日期：`pd.read_excel('file.xlsx', parse_dates=['date_column'])`

## 代码风格指南
**重要提示**：生成 Excel 操作的 Python 代码时：
- 编写简洁精炼的 Python 代码，避免不必要的注释
- 避免冗长的变量名和多余的操作
- 避免不必要的 print 语句

**对于 Excel 文件本身**：
- 为复杂公式或重要假设所在的单元格添加注释
- 为硬编码值注明数据来源
- 为关键计算和模型各部分添加说明备注
