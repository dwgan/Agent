# 项目 Skills 目录

这里用于放置项目级 Skill。Skill 是一套可重复调用的专门工作说明，例如“解析设备日志并生成故障报告”或“按固定步骤检查串口协议实现”。

每个 Skill 使用独立子目录，并在其中提供 `SKILL.md`：

```text
.agents/skills/
└── example-skill/
    └── SKILL.md
```

不要把 `architect`、`coder`、`reviewer` 角色文件放在这里；项目级角色位于 `.codex/agents/`。

新项目开始时可以保留本目录而不创建 Skill。只有某项流程已经稳定、会重复使用，并且单靠 `AGENTS.md` 和普通提示词显得冗长时，再将它封装为 Skill。

模板已经提供：

- `commit-worktree`：检查当前工作目录的 Git 变更，运行适当检查并创建本地提交；默认不推送远程。
- `progress-review`：生成当前进度的俯视总结，用通俗语言解释正在解决的问题和关键决策背后的物理或协议原因；只读，不修改代码。
- `easyeda-environment-setup`：在 Windows 上安装、启动、验证和排查 Codex 与嘉立创EDA之间的官方 Skill、Bridge 和 Gateway；日常 EDA API 操作仍使用部署后的官方 `easyeda-api`。
- `easyeda-pcb-design`：连接已经部署好的嘉立创EDA环境，调用官方 `easyeda-api` 开展原理图、PCB、DRC、拼板和生产检查。日常使用可直接调用 `$easyeda-pcb-design`。
