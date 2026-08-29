# 嘉立创EDA与 Codex 自动化

本专题说明如何把 Codex、官方 `easyeda-api` Skill、Bridge 和 Run API Gateway 连接到嘉立创EDA专业版。

## 最短使用路径

1. 把 `template/` 复制到目标项目根目录。
2. 在 Codex 中调用：

   ```text
   $easyeda-environment-setup 在这台 Windows 电脑上部署并验证嘉立创EDA自动化环境。
   ```

3. 按提示在嘉立创EDA中完成一次 Gateway GUI 导入和外部交互授权。
4. 部署成功后，日常 PCB/原理图查询和操作使用官方 `$easyeda-api`。

详细自动部署要求见 [Codex自动部署指南](Codex自动部署指南.md)。

## 能力边界

- `easyeda-environment-setup`：安装、更新、启动、连接验证和排障。
- 官方 `easyeda-api`：查询或操作工程、PCB、原理图和库。
- Agent 仓库不保存官方 Skill 副本、`node_modules`、Gateway 二进制或运行日志。
- AI 的 API 查询和软件检查不能替代电气审查、DRC、制造审查与真实硬件验收。
