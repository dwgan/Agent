---
name: easyeda-environment-setup
description: 在 Windows 上安装、更新、启动、验证或排查 Codex 与嘉立创EDA专业版之间的 easyeda-api Bridge 和 Run API Gateway 环境。用户要求首次部署、迁移新电脑、修复 Bridge/Gateway 连接、检查端口或重新验收 EasyEDA 自动化环境时使用；日常 PCB、原理图和工程 API 操作应使用官方 easyeda-api Skill。
---

# 嘉立创EDA AI 环境部署

## 目标

建立并验证以下本机链路：

```text
Codex → easyeda-api Skill → Bridge → Run API Gateway → 嘉立创EDA → EDA API
```

本 Skill 只负责环境生命周期。连接成功后的 PCB、原理图和工程操作交给官方 `easyeda-api` Skill。

## 安全边界

- 仅使用 `easyeda/easyeda-api-skill` 和 `easyeda/eext-run-api-gateway` 官方项目。
- 不覆盖来源不明或包含本地修改的 Skill 目录。
- 不卸载现有软件，不修改全局 Git 身份、npm registry、防火墙或执行策略。
- Bridge 必须只监听回环地址，不能暴露到局域网。
- 验收只调用 getter，不创建、修改、删除、保存、切换工程或运行 DRC。
- GUI 无官方自动化入口时，只让用户完成扩展导入和授权，不使用坐标点击脚本。

## 工作流

1. 盘点 Windows、Git、Node.js、npm、Codex、嘉立创EDA、Skill 目录和 49620–49629 端口。
2. 首次部署或更新时，阅读 [references/deployment.md](references/deployment.md)，然后运行 `scripts/Install-EasyEDAEnvironment.ps1`。执行前说明它会访问官方 GitHub 并写入用户级 Skill/Downloads 目录，按当前权限机制申请批准。
3. 使用 `scripts/Start-EasyEDABridge.ps1` 启动或复用 Bridge。
4. 如果 Gateway 尚未安装，只要求用户在嘉立创EDA中导入下载的 `.eext`，并勾选“允许外部交互”和“显示在顶部菜单”。
5. 运行 `scripts/Test-EasyEDAConnection.ps1` 完成 `/health`、`/eda-windows` 和当前工程/文档的只读验收。
6. 连接失败时阅读 [references/troubleshooting.md](references/troubleshooting.md)，按证据逐层定位，不立即重装全部环境。
7. 报告实际版本、端口、连接数、只读 API 结果、未完成项及唯一需要的人工动作。

## 停止条件

- 目标 Skill 目录不是官方仓库：停止更新该目录并报告 remote。
- 官方仓库存在未提交修改：不 pull、不 reset，报告差异。
- 多个 EDA 窗口已连接：列出窗口，让用户选择，不能猜测。
- 需要关闭或重启嘉立创EDA：先提醒用户保存设计，未经确认不终止进程。
- 任何写入 EDA 工程的请求：退出本部署工作流，改用官方 `easyeda-api` Skill并重新确认授权范围。
