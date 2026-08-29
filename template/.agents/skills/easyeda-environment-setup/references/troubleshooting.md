# 连接故障排查

按链路从左到右定位，保留已验证的正常组件。

## Codex 找不到 Skill

1. 检查 `$HOME\.agents\skills\easyeda-api\SKILL.md`。
2. 核验 metadata 中 `name: easyeda-api`。
3. 确认没有在 Codex 配置中禁用该 Skill。
4. 重启 Codex或新开会话。

## Bridge 不健康

1. 扫描 49620–49629，并严格检查 `/health` 的 service 字段。
2. 检查端口占用、Node 进程和 Bridge stdout/stderr 日志。
3. 确认依赖完整，入口来自当前官方 `package.json`。
4. 确认源码监听 `127.0.0.1`，不得为绕过故障改成公网监听。

## Gateway 显示“未找到 Bridge”

1. 从 Windows 本机验证 `/health`。
2. 用独立 WebSocket 客户端访问 `ws://127.0.0.1:<port>/eda`，确认收到 `service=easyeda-bridge` 的 handshake。
3. 确认嘉立创EDA顶部存在 `API Gateway` 菜单。
4. 在扩展管理器确认“允许外部交互”和“显示在顶部菜单”均已勾选；必要时取消后重新勾选并应用。
5. 执行 `API Gateway → Reconnect`。
6. 如果扩展是在嘉立创EDA启动后安装，提醒用户保存设计，再完全退出并重启嘉立创EDA。

## Bridge 已连接但 API 失败

1. 检查 `/eda-windows` 的窗口数和活动窗口。
2. 多窗口时让用户选择。
3. 从官方 references 核对方法名、Promise、参数、枚举与文档类型。
4. 确认 PCB API 对应活动 PCB，SCH API 对应活动原理图。
5. getter 返回 `undefined` 时区分“没有打开工程”和“权限/调用失败”。

不要用重装全部环境代替定位，也不要通过关闭防火墙、放宽执行策略或公网监听解决连接问题。
