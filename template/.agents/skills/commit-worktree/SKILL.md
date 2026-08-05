---
name: commit-worktree
description: 检查并提交当前 Git 工作目录中的已有变更。用户要求提交、保存当前进度、创建本地 commit，或明确调用 $commit-worktree 时使用；提交前检查范围、差异、敏感信息和项目验证，自动生成合适的提交说明。默认只创建本地提交，不推送、不 amend、不跳过 hooks。
---

# 提交当前工作目录

创建一个边界清楚、可回退的本地 Git 提交。只处理用户调用 Skill 时已经存在于当前工作目录范围内的变更，不借机修改功能代码。

## 1. 确认仓库与范围

1. 运行 `git rev-parse --show-toplevel` 和 `git status --short`。
2. 如果当前目录不在 Git 仓库中，停止并说明。
3. 将提交范围定义为当前工作目录及其子目录；如果当前目录就是仓库根目录，则范围为整个仓库。
4. 阅读适用于当前目录的 `AGENTS.md` 和项目提交规则。
5. 检查是否正在 merge、rebase、cherry-pick，是否有未解决冲突。存在异常 Git 状态时停止并报告。
6. 检查暂存区。如果已经暂存了范围外文件，停止并请用户决定，不要把它们混入本次提交，也不要擅自取消暂存。

## 2. 审查待提交内容

1. 查看未暂存差异、已暂存差异、未跟踪文件和差异统计。
2. 区分用户已有改动与本次会话改动，但只要都在用户指定范围内，就作为同一候选提交审查。
3. 确认变更围绕一个清晰目的。若包含明显无关的多组改动，停止并建议拆分提交。
4. 检查 API Key、访问令牌、密码、私钥、客户数据、`.env`、证书、调试转储、大型生成物和不应入库的构建产物。发现可疑内容时不要暂存或提交，先报告具体文件但不要输出秘密值。
5. 不提交被 `.gitignore` 忽略的文件，不用强制参数绕过忽略规则。

## 3. 执行项目检查

1. 根据 `AGENTS.md`、README、构建脚本和本次差异选择安全且与改动成比例的检查。
2. 优先运行快速的格式、静态检查、单元测试或文档检查；不要烧录固件或操作真实硬件。
3. 使用 `git -c core.whitespace=blank-at-eol,blank-at-eof,space-before-tab,cr-at-eol diff --cached --check` 检查暂存差异。该命令将 CRLF 中的 `CR` 识别为合法行尾，但仍报告真实的尾随空格、Tab、空白文件尾和缩进错误。
4. 不得仅因 CRLF 与 LF 不同而阻止提交，也不得为了通过检查而批量重写无关文件的换行符。
5. 如其他检查失败，停止提交并报告失败命令和关键错误。不要用 `--no-verify` 绕过失败。
6. 如果项目没有可识别的自动检查，可以继续，但在结果中明确说明未运行自动测试。

## 4. 暂存并提交

1. 在调用 Skill 时的工作目录执行 `git add -A -- .`，不要用覆盖整个仓库的额外路径。
2. 再次运行 `git status --short` 和 `git diff --cached --stat`，确认暂存范围没有意外文件。
3. 检查完整的已暂存差异；若为空，说明没有可提交内容并结束。
4. 按下一节的规则生成提交信息，然后执行普通 `git commit`。
5. 如果提交钩子失败或修改了文件，停止并重新检查状态；不要反复盲目提交。

## 5. 生成提交信息

按以下优先级选择格式，使用找到的第一项：

1. 用户明确给出的提交信息或格式。
2. `AGENTS.md`、`CONTRIBUTING.md` 或项目文档规定的提交规范。
3. `git log -20 --pretty=format:%s` 显示的近期稳定风格。
4. Conventional Commits 回退格式：`<type>(<scope>): <description>`。

使用 Conventional Commits 回退格式时：

- `scope` 可选，只使用仓库中真实、稳定的模块名；不明确时写成 `<type>: <description>`。
- 使用 `feat` 表示新增功能，使用 `fix` 表示修复缺陷。
- 可按实际目的使用 `docs`、`test`、`refactor`、`perf`、`build`、`ci`、`style`、`chore` 或 `revert`。
- 用简短描述说明实际完成的结果，不写“更新文件”“修改代码”等空泛内容。
- 延续仓库已有的中文或英文风格；如果没有稳定语言风格，使用用户当前使用的语言。
- 一个提交只表达一个主要目的。如果差异包含多个无关目的，返回审查步骤拆分提交。
- 破坏兼容性的变更必须在冒号前添加 `!`，或在脚注中添加 `BREAKING CHANGE: <说明>`。

简单提交只写标题，例如：

```text
fix(storage): prevent metadata loss after power failure
```

复杂提交在标题后空一行增加正文，解释实现和原因；需要记录验证时增加 `Tests:`，且只能列出实际执行过的检查：

```text
feat(skill): add safe worktree commit workflow

Validate the staged scope and repository state before creating a local
commit. Preserve repository-specific commit conventions when present.

Tests:
- skill validation passed
- git diff --check passed
```

简单提交执行 `git commit -m "<subject>"`。包含正文时使用多个 `-m` 参数分别传入标题、正文和脚注。不要自动使用 `--amend`、`--no-verify`、强制参数或签名绕过选项。

## 6. 验证并报告

1. 只有 `git commit` 成功返回后才能报告提交成功。
2. 运行 `git log -1 --oneline` 和 `git status --short`。
3. 报告提交哈希、提交说明、包含的变更范围、执行过的检查，以及提交后仍未提交的文件。
4. 默认不执行 `git push`。只有用户另外明确要求推送时，才进入相应的发布流程。
