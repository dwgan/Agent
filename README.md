# AI Agent 学习资料

这个项目用于整理面向初学者的 AI Agent 使用指导，主要使用嵌入式开发工程师的日常工作作为贯穿案例。

示例领域包括：

- 串口、RS-485、CAN 和以太网数据采集
- 协议解析、缓存和本地数据存储
- STM32、RTOS 和嵌入式 Linux 开发
- 机器人编码器、电机状态机和控制程序
- 软件测试、台架测试和现场验收

## 从这里开始

新电脑或新 Agent 会话应按以下顺序阅读：

1. `AGENTS.md`：项目长期工作规则
2. `docs/HANDOFF.md`：当前进度、已确认结论和下一步
3. `docs/AI-Agent入门与嵌入式开发实践.md`：面向初学者的主文档
4. `docs/OpenAI官方推荐的Codex使用方式.md`：官方最佳实践的中文汇总与嵌入式解读
5. `docs/嵌入式项目工作流快速启动.md`：把工作流用于真实项目的最短路径
6. `docs/嵌入式工程师使用Codex的分阶段开发工作流.md`：工程流程的深入说明
7. `template/`：可直接复制到新项目根目录的多 Agent 模板

## 当前状态

已经完成：

- [AI Agent 入门与嵌入式开发实践](docs/AI-Agent入门与嵌入式开发实践.md)：面向初学者的主文档
- [OpenAI 官方推荐的 Codex 使用方式](docs/OpenAI官方推荐的Codex使用方式.md)：官方最佳实践的汇总、来源和本项目对照
- [嵌入式项目工作流快速启动](docs/嵌入式项目工作流快速启动.md)：可直接复制的项目接管、任务和审查提示词
- [嵌入式项目 AGENTS.md 最小模板](docs/嵌入式项目AGENTS最小模板.md)：新项目的通用安全规则
- [嵌入式工程师使用 Codex 的分阶段开发工作流](docs/嵌入式工程师使用Codex的分阶段开发工作流.md)：工程流程的深入说明
- [新项目多 Agent 模板](template/AGENTS.md)：包含项目规则、自动换行规范化、Codex 配置、architect/coder/reviewer 角色，以及安全提交当前工作目录的 `commit-worktree` Skill
- [嘉立创EDA与 Codex 自动化](docs/easyeda/README.md)：提供轻量部署 Skill、Windows 启动与验收脚本，以及可直接交给 Codex 的自动部署指南

下一步计划是把 `template/` 中的内容复制到一个真实项目根目录，填写项目事实并试用 architect → coder → reviewer 流程，再根据反馈精简规则。

详细状态见 `docs/HANDOFF.md`。
