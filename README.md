# 风铃的模板库

XCPC 算法模板库：按主题分章（图论、数论、数据结构、几何……），原生 Typst 编写，直接编译成 PDF。

## 来源与致谢

部分内容源自以下公开模板库，不逐条对应：

- [hh2048/XCPC](https://github.com/hh2048/XCPC)（WIDA 打印稿）——早期 md 底本的主要来源；部分修补对齐其 v1.8.8
- [fstqwq/Nemesis](https://github.com/fstqwq/Nemesis)（上海交大 2024 WF 打印稿）——虚树板子、网络流建图套路
- SMU_inch 板——二维几何章的自包含板子

## 目录结构

- `main.typ` — 入口：章清单（`#include`）、封面与目录、页码编排
- `theme.typ` — 视觉层：字体、标题、代码块、页眉页脚等全部版式规则
- `prelude.typ` — 宏层：复杂度记号 `#O(...)`、`include-code` 代码读取等
- `chapters/` — 19 个分章，唯一内容源
- `code/` — 按章分目录的独立 C++ 板子，可编译，经 `prelude.typ` 的 `include-code` 读入书中
- `images/` — 书中图片（本地化）
- `code-snippets/` — VS Code 代码片段（`.code-snippets`），按主题分组
- `export/` — 高亮主题、PowerShell 语法定义、字体（细节见 `export/PIPELINE.md`）
- `check.sh` — 验证闸，改动后跑一遍；推 `main` / 开 PR 时 GitHub Actions 也会跑它
- `tests/` — 抽取实际书稿正文运行的回归测试（小规模穷举、朴素参考和数值性质），编译源与日志保留在 `build/regression/`
- `tools/sync_snippets.py` — 检查已登记片段与来源一致；修改来源后用 `--write` 同步对应正文

## 使用

- 分章阅读：打开 `chapters/` 里对应 `.typ`
- VS Code 片段：把 `code-snippets/*.code-snippets` 复制到项目 `.vscode/` 目录，即可在 cpp 文件中用前缀触发

片段与书中代码共用 `code/contest.hpp` 的基础声明；额外依赖按对应小节说明拼接。修改模板时同步书稿、用法和片段，再运行 `./check.sh`。单独运行回归：`python3 -m unittest discover -s tests -p 'test_*.py' -v`。已登记来源之外的历史片段尚未获得同等验证。

## 导出 PDF

```sh
./export-pdf.sh   # 书 + 单独封面，同一日期哈希
```

产物：`build/风铃的模板库-YYYY-MM-DD-<git短哈希>.pdf` 与 `build/封面-YYYY-MM-DD-<git短哈希>.pdf`。单独封面是两行居中的一张纸，不进正文页码。需要：`typst`、章号字体 Montserrat（Debian 包 `fonts-montserrat`）。单章预览：`typst compile --root . --font-path export/vendor/jetbrains-mono chapters/博弈论.typ /tmp/x.pdf`（跨章引用会报未定义，属正常）。

## 克隆与提交

```sh
git clone https://github.com/EmptyDust/Templates-XCPC.git
# 或
git clone git@github.com:EmptyDust/Templates-XCPC.git
```

使用 https 方式提交时网络异常：

```sh
git config --global http.proxy "http://PROXY_ADDRESS:PORT"
git config --global https.proxy "http://PROXY_ADDRESS:PORT"
```
