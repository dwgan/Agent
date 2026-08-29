# Windows 部署说明

## 官方来源

- Skill：`https://github.com/easyeda/easyeda-api-skill.git`
- Gateway：`https://github.com/easyeda/eext-run-api-gateway`
- Releases API：`https://api.github.com/repos/easyeda/eext-run-api-gateway/releases/latest`

不要固定假设版本号。每次部署读取官方仓库当前 `SKILL.md`、README、`package.json` 和锁文件，以实际 scripts 和最低 Node.js 要求为准。

## 环境盘点

记录 Windows/架构、当前用户目录、VS Code 与 OpenAI/Codex 扩展、嘉立创EDA版本和路径、Git/Node/npm 版本，以及 49620–49629 端口。

PowerShell 可能因执行策略拒绝 `npm.ps1`。使用 `npm.cmd` 或 `cmd /c npm` 复核，不要永久放宽执行策略。

## Skill 安装

用户级目标为 `$HOME\.agents\skills\easyeda-api`。Codex 官方会扫描 `$HOME/.agents/skills`；安装后若当前会话未显示，重启 Codex或新开会话。

目标不存在时 clone 官方仓库。目标存在时确认 remote、工作区状态和 `SKILL.md` metadata；只有官方仓库且工作区干净时才允许 fast-forward 更新。依赖优先使用锁文件安装，结束后运行 `npm ls --omit=dev --depth=0`。

README 可能与当前 package scripts 短暂不同步。不得执行 `package.json` 中不存在的构建命令；如果结构化 `references/` 已随仓库提供，应直接验证索引和文档数量。

## Gateway 准备

从最新 release 选择与语言适配的 `.eext`。下载后计算 SHA-256，并读取归档内 `extension.json`，至少核验：

- `name` 为 `run-api-gateway`
- `displayName` 为 `Run API Gateway`
- publisher 为 EasyEDA/JLCEDA 官方
- EDA engine 与本机嘉立创EDA兼容

没有官方 CLI 时，把文件放到 Downloads 并打开所在文件夹。唯一人工步骤是导入扩展、启用扩展，并勾选“允许外部交互”和“显示在顶部菜单”。

## 验收

Bridge 必须在 49620–49629 中选择端口并严格返回 `service=easyeda-bridge`。连接后检查 `/eda-windows`，再调用：

```javascript
const project = await eda.dmt_Project.getCurrentProjectInfo();
const document = await eda.dmt_SelectControl.getCurrentDocumentInfo();
return { project, document };
```

调用前仍需从官方 `references/classes/` 核对签名。当前没有工程时返回 `undefined` 只证明链路可用，不能宣称已检查 PCB 内容。
