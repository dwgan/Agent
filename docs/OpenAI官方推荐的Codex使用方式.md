# OpenAI 官方推荐的 Codex 使用方式

资料核对日期：2026-08-02

## 1. 这份文档解决什么问题

OpenAI 官方资料分散在提示词、`AGENTS.md`、权限、代码审查、MCP、Skills 和自动化等页面中。初学者如果逐页阅读，容易把 Codex 理解成一组需要全部配置的功能。

这份文档把官方建议整理成一条可以直接使用的主线：

```text
给出目标和必要上下文
        ↓
复杂任务先规划
        ↓
用简短的 AGENTS.md 保存长期规则
        ↓
在受限权限内实现
        ↓
运行测试、检查结果、审查差异
        ↓
重复出现的稳定流程再做成 Skill
        ↓
确实需要外部系统时再连接 MCP
        ↓
流程已经可靠后才使用定时任务或并行 Agent
```

这里需要区分两类内容：

- **官方明确建议**：来自 `learn.chatgpt.com` 的 Codex 官方资料。
- **嵌入式落地解释**：根据官方原则，结合串口、网络、存储和电机控制项目得出的工程建议。

OpenAI 官方资料主要讨论通用软件开发。示波器、逻辑分析仪、掉电测试和真实电机安全验收等要求，是本项目针对嵌入式开发增加的工程边界，不应误写成 OpenAI 官方原话。

---

## 2. 官方建议的核心结论

### 2.1 把 Codex 当作持续协作的工程伙伴

官方最佳实践建议，不要只把 Codex 当作一次性问答工具，而应当逐步给它正确上下文、长期项目规则、真实构建环境和可验证的完成条件。配置也应从实际摩擦中生长，而不是第一天就把所有功能接上。

这意味着：

- 第一次接触仓库时，先让 Codex 理解项目；
- 发现重复错误后，再补充长期规则；
- 一种提示词重复有效后，再考虑 Skill；
- 外部资料反复需要时，再连接 MCP；
- 流程手工执行已经稳定后，再考虑定时运行。

来源：[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

### 2.2 一个好任务只需要四类信息

官方最佳实践使用四个要素组织 Codex 任务：

| 官方要素 | 通俗解释 | 嵌入式示例 |
|---|---|---|
| Goal | 要得到什么结果 | 修复 RS-485 半帧后无法继续解析的问题 |
| Context | 哪些资料会影响结果 | 协议文档、解析器、失败日志和测试 |
| Constraints | 哪些边界不能突破 | 不修改驱动、波特率和电机控制 |
| Done when | 什么条件表示完成 | 回归测试通过，错误后可以重新同步 |

官方提示词指南也使用相近的结构：目标、上下文、输出和边界，并强调只提供真正影响结果的内容，不要求填写固定格式或控制 Agent 的每个步骤。

来源：[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)、[Prompting](https://learn.chatgpt.com/docs/prompting)

可直接用于嵌入式项目的最小提示词：

```text
目标：修复流式解析器收到半帧后无法继续解析的问题。

上下文：请读取 protocol/、tests/protocol/ 和协议文档，
并先复现已有失败测试。

限制：不修改 drivers/、motor/、通信参数和芯片配置。

完成条件：
- 半帧后可以继续接收并完成解析
- CRC 错误不输出有效数据
- 相关回归测试通过
- 报告实际运行的命令和未验证项
```

### 2.3 从结果出发，不必先写完整操作步骤

官方提示词指南建议先描述需要的结果。只有当过程本身很重要时，才需要规定步骤；否则可以让 Codex 自行搜索、比较和调整方法。

对嵌入式工程师来说，这可以减少提示词负担：

```text
不必写：
先打开 A 文件，再搜索 B 函数，再读取 C 文件……

可以写：
请梳理 UART3 从 DMA 接收到协议解析的完整数据流，
列出关键文件、任务、中断、缓冲区和依据。
```

工程师仍应规定真正重要的过程，例如“先只读”“复杂方案先规划”“不得操作真实硬件”。

来源：[Prompting](https://learn.chatgpt.com/docs/prompting)

---

## 3. 复杂任务先规划

官方明确建议：当任务复杂、含糊或难以描述时，先让 Codex 规划，再开始写代码。官方列出的做法包括：

- 使用 Plan mode；
- 让 Codex 先向用户提问并挑战不明确的假设；
- 对很长的多阶段工作使用执行计划模板。

简单局部修复不必强制写长计划。下面这些嵌入式任务更适合先规划：

- 修改中断与线程之间的数据所有权；
- 重构 DMA、环形缓冲区或任务优先级；
- 设计存储掉电一致性；
- 改变网络重试和数据丢弃策略；
- 修改电机状态机、故障恢复和安全保护；
- 修改范围较大或难以回退。

可复制提示词：

```text
这个任务涉及串口 DMA、解析任务和缓存所有权。
请先进入计划阶段，不要修改文件。

请读取当前实现，列出：
1. 已确认事实和代码依据；
2. 尚未确认的假设和资料冲突；
3. 可能推翻方案的高风险问题；
4. 最小验证实验；
5. 分阶段修改范围、测试方法和回退方案。

等我确认后再实现。
```

来源：[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)、[Prompting](https://learn.chatgpt.com/docs/prompting)

---

## 4. 用简短的 `AGENTS.md` 保存长期规则

官方把 `AGENTS.md` 定位为会随仓库一起存在的长期项目指导。适合写入：

- 仓库结构和重要目录；
- 项目的运行方式；
- 构建、测试和检查命令；
- 工程规范和评审要求；
- 禁止事项；
- 怎样才算完成，以及怎样验证。

官方同时强调：短而准确的 `AGENTS.md` 比充满模糊规则的长文件更有用。先写基础内容，只有在出现重复错误或重复评审意见后再增加规则。

官方还说明了指导文件的层级：

- 用户级指导可以保存个人通用习惯；
- 仓库根目录保存全项目规则；
- 子目录可以有更具体的规则；
- 越靠近当前工作目录的指导优先级越高。

Codex CLI 还提供 `/init` 来生成一个初始 `AGENTS.md`，但官方提醒需要根据团队真实的构建、测试和交付方式修订生成结果。

来源：[Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

对于嵌入式项目，推荐保持三层分工：

| 内容 | 放在哪里 |
|---|---|
| 长期构建命令、目录规则、安全边界 | `AGENTS.md` |
| 当前架构、硬件版本和阶段状态 | 架构或状态文档 |
| 本次目标、范围和验收标准 | 当前提示词 |

不要把协议全文、全部架构历史、当前所有缺陷和每次任务要求都塞进 `AGENTS.md`。

---

## 5. 配置真实环境，但从默认权限开始

官方指出，很多看似是模型质量的问题，其实来自环境配置：工作目录错误、缺少写权限、缺少构建工具，或者没有连接需要的资料来源。

官方建议新用户从默认权限开始，保持沙箱和审批边界较紧，只在可信仓库或明确工作流中按需增加权限。

**沙箱（sandbox）** 是限制 Agent 可以访问哪些文件和网络资源的技术边界。**审批策略** 决定 Agent 什么时候必须停下来请求允许。两者配合后，Agent 可以在已批准范围内连续完成低风险工作，同时在越界时暂停。

官方把 `workspace-write` 描述为本地工作的低摩擦模式：允许在工作区内读写并运行常规本地命令，访问网络或越过工作区时再请求批准。完全访问会移除这些边界，只应在明确需要并愿意承担风险时使用。

来源：[Sandbox](https://learn.chatgpt.com/docs/sandboxing)、[Permissions](https://learn.chatgpt.com/docs/permissions)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

嵌入式项目还应在通用权限之外增加人工安全关口：

- 本地文件写权限不等于获得烧录设备的授权；
- 可以运行 PC 单元测试不等于可以控制真实电机；
- 可以访问网络不等于可以向生产系统写入；
- 自动审批不能代替现场安全责任人。

---

## 6. 不只生成代码，还要测试和审查

官方建议不要在 Codex 写完代码后就结束任务。还应要求它：

- 必要时编写或更新测试；
- 运行相关测试套件；
- 执行格式、静态或类型检查；
- 确认最终行为满足任务要求；
- 检查差异中的缺陷、回归和风险。

Codex 的 `/review` 可以审查：

- 相对基础分支的差异；
- 当前未提交改动；
- 指定提交；
- 带有自定义审查重点的改动。

官方代码审查文档说明，专用审查会报告有优先级、可操作的问题，并且默认不修改工作树。工程师可以进一步要求证据、缩小审查范围，或选择让 Codex 修复其中部分问题。

来源：[Code review](https://learn.chatgpt.com/docs/code-review)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

嵌入式项目中的推荐闭环是：

```text
Codex 实现
  ↓
运行编译、静态检查、单元测试和模拟测试
  ↓
工程师查看差异
  ↓
使用 /review 或独立会话审查
  ↓
修复已确认问题并回归
  ↓
工程师进行真实硬件验收
```

自动测试和代码审查无法验证真实串口时序、网络抓包、掉电结果、电机方向和急停行为。

---

## 7. 只在真正需要时增加 MCP、Skills 和自动化

### 7.1 MCP：外部上下文不在仓库中时使用

官方建议在这些情况下使用 MCP：

- 所需资料在仓库之外；
- 数据频繁变化；
- 希望 Codex 调用真实工具，而不是依赖复制粘贴；
- 多人或多项目需要重复使用同一个外部集成。

官方同时建议，不要一开始把所有工具都接入。先选择一两个能够明显消除重复手工步骤的工具。

嵌入式例子：

- GitHub 中的 Issue 和评审意见反复需要读取；
- 团队协议文档存放在外部文档系统；
- 测试结果保存在可查询的内部数据库。

来源：[Model Context Protocol](https://learn.chatgpt.com/docs/extend/mcp)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

### 7.2 Skill：同一种方法反复使用时封装

官方建议，当一种提示词或纠正流程反复出现时，把它整理成 Skill。每个 Skill 应聚焦一个任务，先从少量真实用例开始，明确输入、输出和触发条件，不要第一版就覆盖所有边界情况。

适合嵌入式团队的 Skill 候选：

- 串口协议解析器审查；
- 故障日志分类；
- 固件发布前检查；
- 电机状态机只读安全审查；
- 阶段验收记录整理。

来源：[Build skills](https://learn.chatgpt.com/docs/build-skills)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

### 7.3 定时任务：手工流程已经可靠后再使用

官方建议只把已经稳定的流程安排为定时任务。Skill 定义“怎样做”，定时任务定义“什么时候做”。如果任务每次仍需要大量人工引导，应先改进提示词或 Skill，而不是立即无人值守运行。

适合的低风险例子：

- 汇总最近提交；
- 检查 CI 失败；
- 草拟发布说明；
- 定期检查文档链接；
- 执行只读的代码或日志分析。

不适合无人值守执行：烧录固件、控制电机、解除故障、改变生产设备参数或对现场系统执行写操作。

来源：[Scheduled tasks](https://learn.chatgpt.com/docs/automations)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

---

## 8. 管理会话和并行工作

官方建议一个会话围绕一个连贯的工作结果。只要仍在解决同一个问题，保留原会话有利于延续上下文；任务真正分叉时再创建新的会话。把整个项目的所有工作都放进一个无限增长的会话，会导致上下文臃肿和结果变差。

官方也建议把子 Agent 用于边界明确的探索、测试或问题分类，让主 Agent 保持在核心任务上。并行任务如果可能编辑相同文件，应使用隔离的 Git worktree，而不是让多个任务同时修改同一工作目录。

嵌入式项目可以这样分工：

```text
主会话：实现当前协议解析阶段

独立会话 A：只读审查缓冲区边界和错误恢复
独立会话 B：检查已有测试遗漏

工程师：合并判断，决定修复和真实硬件验收
```

不要把同一个函数同时交给多个 Agent 修改。并行化更适合互不写冲突的只读分析或隔离工作区任务。

来源：[Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)、[Git worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees)、[Codex Best practices](https://learn.chatgpt.com/guides/best-practices)

---

## 9. 官方建议对应的日常开发流程

把上述建议压缩后，日常使用可以非常简单。

### 新项目第一次接管

```text
打开完整仓库
→ 从默认或较紧权限开始
→ 让 Codex 只读理解项目
→ 确认构建、测试、目录和安全规则
→ 建立简短 AGENTS.md
```

### 一个普通局部任务

```text
说明 Goal、Context、Constraints、Done when
→ Codex 实现最小改动
→ Codex 运行相关检查
→ 工程师查看差异
→ /review 或独立会话审查
→ 工程师完成必要的硬件验收
```

### 一个复杂任务

```text
Codex 先读取上下文
→ Plan mode 或让 Codex 先提问
→ 工程师确认计划和风险实验
→ 分阶段实现
→ 每阶段测试、审查和回退
```

### 流程成熟以后

```text
重复规则 → AGENTS.md
重复工作方法 → Skill
外部动态资料 → MCP
稳定周期任务 → Automation
可并行且边界清晰的子任务 → Subagent / worktree
```

---

## 10. 官方建议与本项目工作流的对应关系

| OpenAI 官方建议 | 本项目已有做法 | 结论 |
|---|---|---|
| 提示词包含目标、上下文、限制和完成条件 | 目标、范围、限制和验收标准 | 基本一致 |
| 复杂任务先规划 | 高风险实验后再确定架构 | 本项目进一步加强风险验证 |
| 用简短 `AGENTS.md` 保存长期规则 | 提供最小 `AGENTS.md` 模板 | 一致 |
| 从默认或紧权限开始 | 只读接管、工作区内安全修改、越界确认 | 一致 |
| 写代码后运行测试并审查差异 | 主 AI 测试、独立 AI 审查 | 一致 |
| MCP 只连接确实需要的外部系统 | 不为本地任务提前配置 MCP | 一致 |
| 重复流程稳定后再做 Skill | 快速启动包先人工试用，再考虑 Skill | 一致 |
| 稳定后再安排定时任务 | 不自动执行真实设备工作 | 本项目增加硬件安全边界 |
| 一个会话对应一个连贯结果 | 一个会话聚焦当前阶段 | 一致 |
| 并行修改用隔离工作区 | 独立审查默认只读 | 本项目采用更保守的嵌入式策略 |

因此，当前项目不需要推翻已有工作流。官方资料反而支持“先最小配置、再从真实重复需求中逐步增加能力”的方向。

---

## 11. 初学者最容易犯的错误

综合官方最佳实践，常见错误包括：

1. 把所有长期规则都重复塞进每次提示词。
2. 不告诉 Codex 怎样构建、测试和判断完成。
3. 多步骤复杂任务跳过规划。
4. 一开始就授予整台电脑的完全访问权限。
5. 多个任务同时修改同一个工作目录。
6. 流程还不稳定就安排定时运行。
7. 把整个项目所有工作放在一个无限增长的会话里。
8. 要求 Codex 写代码，却不要求它测试、检查和报告未验证项。

嵌入式项目还要额外避免：

9. 把软件测试通过当成真实硬件验收通过。
10. 允许 AI 自动烧录、使能电机、解除急停或提高安全上限。
11. 把数据手册、旧文档或 AI 推测直接当成已确认事实。

---

## 12. 推荐采用的最小版本

如果不想花时间配置，实际只使用下面四项就够了：

1. 项目根目录有一份简短、准确的 `AGENTS.md`。
2. 每次任务说明目标、必要上下文、关键限制和完成条件。
3. 复杂任务先规划，普通局部任务直接实现和测试。
4. 完成后查看差异、运行 `/review` 或独立审查，再进行必要的人工验收。

可以直接使用本项目已经准备好的：

- [嵌入式项目工作流快速启动](./嵌入式项目工作流快速启动.md)
- [嵌入式项目 AGENTS.md 最小模板](./嵌入式项目AGENTS最小模板.md)
- [嵌入式工程师使用 Codex 的分阶段开发工作流](./嵌入式工程师使用Codex的分阶段开发工作流.md)

等到一种流程确实反复出现，再决定是否增加 Skill、MCP、定时任务或多 Agent。这样既符合 OpenAI 官方建议，也不会让“配置 AI”本身变成一个新项目。

---

## 13. 本次使用的官方资料

- [Codex Best practices](https://learn.chatgpt.com/guides/best-practices)
- [Prompting](https://learn.chatgpt.com/docs/prompting)
- [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Customization](https://learn.chatgpt.com/docs/customization/overview)
- [Sandbox](https://learn.chatgpt.com/docs/sandboxing)
- [Permissions](https://learn.chatgpt.com/docs/permissions)
- [Code review](https://learn.chatgpt.com/docs/code-review)
- [Model Context Protocol](https://learn.chatgpt.com/docs/extend/mcp)
- [Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Scheduled tasks](https://learn.chatgpt.com/docs/automations)
- [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Git worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees)

产品界面、命令和配置能力可能更新。本文记录的是 2026-08-02 核对到的官方建议；后续涉及具体配置字段或界面位置时，应重新查看对应官方页面。
