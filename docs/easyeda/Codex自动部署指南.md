# Codex + 嘉立创EDA自动部署指南

这份文档可直接交给另一台 Windows 电脑上的 Codex：

```text
请打开本仓库，阅读 AGENTS.md，然后使用
$easyeda-environment-setup
在这台电脑上自动部署并验证 Codex + 嘉立创EDA环境。

请直接完成环境盘点、官方 Skill 安装、依赖安装、Bridge 启动、Gateway 准备和只读验收。除非必须由用户在嘉立创EDA GUI 中导入扩展或授予“允许外部交互”，否则不要停下来让我执行终端命令。不得修改任何现有 EDA 工程。
```

## 预期链路

```text
Codex
→ easyeda-environment-setup（本仓库负责部署）
→ easyeda-api（部署时从 EasyEDA 官方仓库安装）
→ Bridge（仅监听 127.0.0.1）
→ Run API Gateway（嘉立创EDA扩展）
→ 嘉立创EDA EDA API
```

## 官方来源

- <https://github.com/easyeda/easyeda-api-skill>
- <https://github.com/easyeda/eext-run-api-gateway>
- <https://github.com/easyeda/eext-run-api-gateway/releases>

## 验收结果

部署完成后至少确认：

- Codex 能发现 `easyeda-api`。
- Bridge `/health` 返回 `service=easyeda-bridge`。
- `/eda-windows` 至少检测到一个窗口。
- 当前工程和文档信息的只读 API 调用成功。
- Bridge 仅监听本机回环地址。
- 没有对现有 EDA 工程执行任何写操作。

更完整的部署和故障处理细节由 Skill 的 `references/` 按需加载，重复操作由 `scripts/` 执行。
