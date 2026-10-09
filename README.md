# SubCraft × 深海迷航 —— Windows 一键包

**在《深海迷航》里用 Minecraft 的角色、物理和方块玩。**

隐藏运行一份真正的 Minecraft：**Minecraft 拥有玩家**（物理、背包、战斗、方块、怪物），
**《深海迷航》拥有世界**（地形、生物、光照、音效、存档）并负责画面上每一个像素。
两边的数据通过一块共享内存交换，深海迷航自己的地形**完全不被修改**（海底只是被"镜像"成
Minecraft 侧的幽灵方块，好让 MC 的物理与怪物逻辑能正常工作）。

> 本项目是对 **[SubCraft](https://github.com/FumperForrest/SubCraft)**（作者 FumperForrest，MIT）
> 的 Windows 打包与补丁集，架构源自 **[SkyCraft](https://github.com/chasmlol/SkyCraft)**（MIT）。
> 上游、本包与全部改动的关系见 [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) 与 [`patches/`](patches/)。

---

## 0. 你需要先有的东西（本包不包含游戏本体）

| 必需 | 说明 |
|---|---|
| **Windows 10/11** | 本包只做了 Windows |
| **《深海迷航》正版**（Steam） | 本包不包含游戏本体，也不包含任何从游戏里提取的资源 |
| **Minecraft: Java 版**（正版账号） | 需要你自己拥有；**本包不再分发 Minecraft**（Mojang EULA 不允许） |
| **一个能装 NeoForge 的启动器** | 推荐 **PCL2**（Plain Craft Launcher 2）；HMCL、Prism 等也可以 |
| **Java 21** | NeoForge 1.21.1 需要 Java 21；PCL2 一般会自动下载 |

---

## 1. 安装（约 10 分钟）

### 1.1 在启动器里准备 Minecraft 侧

1. 用启动器安装 **Minecraft 1.21.1**，再给它装 **NeoForge 21.1.x**（PCL2：版本设置 → 安装 NeoForge）。
2. 把这个版本**至少启动一次**到主菜单，然后退出（让启动器把依赖补全）。
3. 打开这个版本的游戏目录（PCL2：版本设置 → 打开版本文件夹），把本包里的
   **`mods/subcraft-<版本>.jar`** 复制进 **`mods`** 文件夹（没有就新建）。
4. （建议）这个版本不要装别的 mod：SubCraft 会接管整个世界，其它 mod 可能冲突。

### 1.2 安装《深海迷航》侧

1. 把本包解压到**《深海迷航》的游戏根目录**（即 `Subnautica.exe` 所在目录，Steam 里：
   库 → 右键 深海迷航 → 管理 → 浏览本地文件）。
2. 右键 `install\install.ps1` → **用 PowerShell 运行**（或在该目录执行
   `powershell -ExecutionPolicy Bypass -File install\install.ps1`）。
   它会：
   - 把 **BepInEx 5.4.23.5** 与 **`SubCraft.dll`** 装进游戏目录（纯新增文件，不动游戏原文件）；
   - 生成一份**专属于你的 Steam 启动选项**（见 1.3）；
   - **拒绝在游戏运行时安装**。

### 1.3 在 Steam 里加启动选项

打开生成的 **`SubCraft\steam-launch-options.txt`**，把里面那一行**整行**复制到：

> Steam → 库 → 右键《深海迷航》→ 属性 → **通用** → **启动选项**（就是"高级用户可以选择输入对启动选项的修改"那个框）

那一行的作用：**先把你配置的 Minecraft 启动器拉起来**，再启动游戏。

```bat
cmd /c start "" "<你的游戏目录>\SubCraft\start-mc.cmd" & %command%
```

> `start-mc.cmd` 里第一行是 `set MC_LAUNCH=`，默认会打开 PCL2。
> 如果你的启动器支持命令行直接启动某个版本，把它改成对应命令即可。

---

## 2. 开始玩

1. **从 Steam 启动《深海迷航》**（启动选项会自动先把 Minecraft 拉起来）。
   Minecraft 会**隐藏窗口**、自动打开自己的 `SubCraft Dev` 世界，然后**等待**深海迷航接入。
2. 在《深海迷航》里**新建或载入一个存档**（建议**创造模式**，见下面"第一次玩"）。
3. 加载过程中两边就会接上；进地图后你会看到：
   - 你的角色变成了 **Minecraft 的**（第一人称手部、FOV、视角晃动、F5 三人称）；
   - 走路/游泳是 Minecraft 的物理，撞到的是深海迷航**精确的**海底；
   - 画面仍然是深海迷航的：阳光、雾、水下焦散、手电筒、载具灯照在 MC 的方块上都成立。

**按键归属**：WASD / 空格 / Shift / Ctrl / E 背包 / F5 视角 / 1-9 快捷栏 / Q 丢弃 是 **Minecraft** 的；
**Tab** 是深海迷航的 PDA，**Esc** 是深海迷航的暂停，**F11** 切换游戏全屏。

### 第一次玩建议

- 用**创造模式**：E 打开的是 MC 的创造物品栏，方块随便拿。
- 想体验生存：MISSION 的默认设定是 **Minecraft 侧创造**；可在 MC 里 `/gamemode survival`。
- **海蛾号（Seamoth）**：上船时控制权交回深海迷航，下船立刻回到 MC 角色。

---

## 3. 卸载

1. 把 Steam 启动选项里的那一行**清空**；
2. 删除游戏目录下的 `winhttp.dll`、`doorstop_config.ini`、`.doorstop_version`、`BepInEx\`、`SubCraft\`；
3. 从你的 MC 版本里删掉 `mods\subcraft-0.0.1.jar`。

**你的存档**：本包默认**不读写你的存档**（开发用的读档/存档命令需要先显式配置开发存档槽）。
深海迷航的地形在世界层面不会被修改。

---

## 4. 已知限制（诚实清单）

| 现象 | 说明 |
|---|---|
| **海底挖不动** | 设计如此：海底是"幽灵方块"，只用来给 MC 提供碰撞；**你自己放下的方块**可以正常挖掉 |
| MC 背包里看不到深海迷航的物品 | 已实现**单向**物品桥：深海迷航里拾取的东西会变成 MC 物品（同名中文名）；反向（MC → 深海迷航）还没做 |
| 深海迷航捡到的物品仍在深海迷航背包里 | 当前是"复制"不是"搬运"，等反向桥定了再改成搬运 |
| 飞行时可能卡顿 | 世界是 2032 层水的平坦世界，生成新区块开销大；正在改造成本更低的生成器 |
| 地图边缘/虚空会下沉 | 深海迷航**自己**的地形碰撞只有相机周围 5×5×5 个 16 格单元，窗口外没有地面 |
| 个别模型的碰撞网格读不出 | 会用包围盒代替（日志里有 `collision mesh ... isn't readable`） |

---

## 5. 从源码构建（可选）

```powershell
# 1) 拉取被固定的上游提交，并打上本仓库的补丁
powershell -ExecutionPolicy Bypass -File scripts\fetch-upstream.ps1

# 2) 构建两侧
powershell -ExecutionPolicy Bypass -File scripts\build-host.ps1     # 需要 .NET SDK
powershell -ExecutionPolicy Bypass -File scripts\build-guest.ps1    # 需要 JDK 21 + Gradle wrapper

# 3) 打发布 zip
powershell -ExecutionPolicy Bypass -File scripts\make-pack.ps1
```

补丁见 [`patches/host.patch`](patches/host.patch) 与 [`patches/guest.patch`](patches/guest.patch)，
基线提交记录在 [`patches/UPSTREAM_COMMIT.txt`](patches/UPSTREAM_COMMIT.txt)。

---

## 6. 法律与致谢

- 本仓库**只发布代码、补丁与脚本**，不包含《深海迷航》或 Minecraft 的任何游戏文件/资源；
- Minecraft 由你**自己的账号**从官方渠道获取；《深海迷航》由 Steam 提供；
- 上游 SubCraft（MIT，FumperForrest）与 SkyCraft（MIT，chasmlol）的声明见
  [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md)；
- 桌面/Steam 存档属于你自己的游戏，本包不对其做任何修改。

**许可**：本仓库的脚本、补丁与文档以 **MIT** 发布（见 [`LICENSE`](LICENSE)）。
