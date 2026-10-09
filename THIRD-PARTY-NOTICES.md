# 第三方声明

本包**不包含**《深海迷航》或 Minecraft 的任何游戏文件、资源或反编译代码。
游戏本体必须由用户自己拥有（Steam / 微软账号），资源一律在用户自己的机器上、从用户自己的安装中读取。

## 上游项目

| 项目 | 作者 | 许可 | 与本包的关系 |
|---|---|---|---|
| [SubCraft](https://github.com/FumperForrest/SubCraft) | FumperForrest | **MIT** | 本包的直接基线。`patches/` 里的补丁应用到 `patches/UPSTREAM_COMMIT.txt` 记录的那个提交上；上游的 MIT 声明与版权归其作者。 |
| [SkyCraft](https://github.com/chasmlol/SkyCraft) | chasmlol | **MIT** | SubCraft 的架构来源（"隐藏的 guest + 宿主绘制"路线）。SubCraft 与 SkyCraft 均声明保留其 MIT 许可。 |
| [BepInEx](https://github.com/BepInEx/BepInEx) 5.4.23.5 | BepInEx 团队 | **LGPL-2.1** | 作为《深海迷航》侧的插件加载器**原样再分发**（未修改）。见其发行包内的 `LICENSE`。 |
| [NeoForge](https://github.com/neoforged/NeoForge) / Minecraft Forge | NeoForged 团队 | **LGPL-2.1** | 由用户在自己的启动器里安装，本包不再分发。 |
| Minecraft: Java Edition | Mojang / Microsoft | 专有 | **不再分发**。用户必须拥有正版并通过官方渠道下载。 |

## 本包自己的代码

- `install/`、`scripts/`、`docs/`、`README.md`：MIT（见 `LICENSE`）。
- `patches/`：对上游 MIT 代码的修改，仍按 MIT 授权，版权归原作者，改动部分归本仓库作者。

## 不做什么

- 不绕开任何 DRM 或反作弊；
- 不修改游戏本体文件（安装只新增文件，卸载即删除）；
- 不触碰玩家的存档（开发用的读档/存档命令要求先显式配置一个专用开发存档槽）。
