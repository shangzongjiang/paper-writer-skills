# *ACL 论文样式

本目录包含 *ACL 系列会议的最新 LaTeX 模板。

## 作者须知

向 *ACL 系列会议投稿的论文必须使用官方 ACL 样式模板。

LaTeX 样式文件可从以下渠道获取：

- [Overleaf 模板](https://www.overleaf.com/latex/templates/association-for-computational-linguistics-acl-conference/jvxskxpnznfj)
- 本代码仓库
- [.zip 压缩包](https://github.com/acl-org/acl-style-files/archive/refs/heads/master.zip)

示例请参见 [`acl_latex.tex`](https://github.com/acl-org/acl-style-files/blob/master/acl_latex.tex)。

请遵循 *ACL 系列会议通用的论文格式规范：

- [论文格式规范](https://acl-org.github.io/ACLPUB/formatting.html)

作者不得修改这些样式文件，也不得使用为其他会议设计的模板。

## 出版主席须知

如需为贵会议适配样式文件，请 fork 本仓库并进行必要修改。最少需要更新会议名称并重命名相关文件。

如果您对模板进行了改进且希望传播至未来的会议，请提交 pull request，感谢您的贡献！

在旧版模板中，作者需要填写 START 投稿 ID，以便在匿名版本的每页顶部打印该编号。现在已无需如此，因为 START 系统已可自动完成该盖章操作。目前的做法是由程序主席发送邮件至 support@softconf.com 申请开启此功能。

## 样式文件修改流程说明

- 在 github 上合并 pull request，或直接推送至 github
- 从 github 拉取到本地仓库（git pull）
- 再从本地仓库推送到 Overleaf 项目（git push）
    - Overleaf 项目地址：https://www.overleaf.com/project/5f64f1fb97c4c50001b60549
    - Overleaf git 地址：https://git.overleaf.com/5f64f1fb97c4c50001b60549
- 最后在 Overleaf 中点击"Submit"，再点击"Submit as Template"，请求 Overleaf 从该项目更新 Overleaf 模板
