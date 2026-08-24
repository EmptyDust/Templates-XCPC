# 风铃的模板库

XCPC 算法模板库：按主题分章（图论、数论、数据结构、几何……）+ VS Code 代码片段 + 合并单文件。

## 目录结构

- `*.md` — 按主题分章，每章末尾带分页标记，可用浏览器打印或转 PDF
- `code-snippets/` — VS Code 代码片段（`.code-snippets`），按主题分组
- `total.md` — 全部章节的合并单文件，由 `build.sh` 生成，**不要手改**
- `export/` — PDF 导出管线（技术细节见 `export/PIPELINE.md`）

## 使用

- 分章阅读：打开对应 `.md`；全文检索用 `total.md`
- VS Code 片段：把 `code-snippets/*.code-snippets` 复制到项目 `.vscode/` 目录，即可在 cpp 文件中用前缀触发
- 打印：浏览器打开 `.md` 渲染结果后打印；各章末尾的分页标记保证章节另起一页

## 重新生成 total.md

修改分章后运行：

```sh
./build.sh
```

## 导出 PDF

默认走 Typst 链路：`pandoc` 把 Markdown（含 `$...$` LaTeX）转成 Typst 标记，`typst` 直接排版成 PDF。源文件不依赖任何渲染器特性。

```sh
./export-pdf.sh           # build/total.pdf
./export-pdf.sh 博弈论.md  # build/博弈论.pdf
```

需要：`pandoc`、`typst`。管线细节、已知坑、旧 Chromium 链路见 `export/PIPELINE.md`。

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
