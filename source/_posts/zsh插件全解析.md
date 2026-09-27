---
title: zsh 插件全解析：我当前用的 15 个插件都在干什么
categories:
  - 技术笔记
tags:
  - zsh
  - oh-my-zsh
  - Ubuntu
  - 效率工具
  - 终端
abbrlink: 19904
date: 2026-09-27 09:20:00
---

之前写过一篇 [Terminator 全部内置插件功能详解](/posts/45895.html)，那是终端模拟器这一层的。这篇往下走一层，记录我现在 zsh 里装的插件。

环境：Ubuntu 24.04 + zsh + oh-my-zsh + powerlevel10k 主题。

<!-- more -->

## 一、先厘清三个层次

终端这东西是三层套娃，搞清楚了才知道插件装在谁身上：

```
Terminator（终端模拟器，管窗口和分屏）
  └── zsh（shell，管命令解释）
        └── vim / python / ros2（跑在 shell 里的程序）
```

顺带一个冷知识：本机 `vi`、`vim`、`nvim` 三个命令**是同一个程序**（Neovim 0.9.5），通过 `/etc/alternatives` 软链过去的。验证方法：

```bash
md5sum /usr/bin/nvim /usr/bin/vim
# 输出一致，说明是同一份二进制
```

## 二、插件总览

| 插件 | 类型 | 一句话用途 |
|---|---|---|
| git | 日常 | git 别名和分支补全 |
| sudo | 日常 | 连按两次 Esc 给上条命令补 sudo |
| extract | 日常 | 一个 `x` 命令解压所有格式 |
| colored-man-pages | 日常 | man 手册彩色显示 |
| command-not-found | 日常 | 命令不存在时提示装哪个包 |
| history-substring-search | 日常 | 输前缀按 ↑ 只翻匹配历史 |
| docker / docker-compose | 开发 | docker 命令补全 |
| pip / python | 开发 | Python 相关补全 |
| zoxide | 导航 | `z` 命令跳常用目录 |
| zsh-completions | 导航 | 补充大量命令的补全规则 |
| fzf-tab | 导航 | 用模糊搜索界面替换 Tab 补全 |
| zsh-autosuggestions | 输入 | 历史命令灰色提示 |
| zsh-syntax-highlighting | 输入 | 命令语法着色 |

## 三、逐个说明

### 1. git（oh-my-zsh 自带）

最高频的其实是那一堆缩写，用熟了能少敲一半键：

| 别名 | 原命令 |
|---|---|
| `gst` | git status |
| `ga` | git add |
| `gcmsg "xxx"` | git commit -m "xxx" |
| `gco` | git checkout |
| `gcb` | git checkout -b |
| `gp` | git push |
| `gl` | git pull |
| `gd` | git diff |
| `glog` | 图形化 log |

### 2. sudo

**忘打 sudo 时的救命键。** 敲完 `apt install tmux` 提示权限不够，不用重新敲一遍，连按两下 `Esc`，命令行自动变成 `sudo apt install tmux`。

### 3. extract

```bash
x xxx.tar.gz
x xxx.zip
x xxx.7z
```

一个命令搞定所有压缩格式，不用再记 `tar -xzvf` / `tar -xjf` / `unzip` 那些参数了。

### 4. colored-man-pages

`man` 手册加配色。看 CUDA、ROS 的手册时层次清楚很多。

### 5. command-not-found

```bash
$ ifconfig
命令 'ifconfig' 未找到，可以通过以下命令安装：
sudo apt install net-tools
```

### 6. history-substring-search

输入 `docker` 再按 ↑，只翻 `docker` 开头的历史命令，不是所有历史。比 `Ctrl+R` 直观。

需要在 `.zshrc` 里补两行绑定，否则部分终端里 ↑↓ 不生效：

```zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
```

### 7. docker / docker-compose

补全 `docker run --xxx` 那一长串参数，还有容器名、镜像名。装了 Docker Desktop 的话很实用。

### 8. pip / python

补全 pip 子命令和已安装的包名。

### 9. zoxide（需要另外装）

`z` 命令跳转目录，按访问频率和最近程度排序：

```bash
z ros      # 跳到最常去的、名字含 ros 的目录
z code     # 跳到 ~/code
zi         # 交互式选择（配合 fzf）
```

比 autojump 快，而且维护更活跃。**它和 autojump 可以共存**——zoxide 用 `z`，autojump 用 `j`，命令不冲突，只是两个数据库不互通。用一段时间觉得哪个顺手就留哪个。

### 10. zsh-completions

补充大量命令的补全规则，很多工具自带的 zsh 补全不全，这个补丁补齐。

### 11. fzf-tab（需要另外装）

把 Tab 补全的菜单换成 fzf 的模糊搜索界面，可以边输入边过滤，能预览文件内容。补全长路径时特别爽。

### 12. zsh-autosuggestions

输入命令时，用过的历史命令会以灰色显示，按 `→` 直接采用。

### 13. zsh-syntax-highlighting

命令正确显示绿色，错误显示红色，敲错在回车前就能发现。

## 四、外部工具：fzf

fzf 本身不是 oh-my-zsh 插件，是一个独立的模糊搜索工具，装上之后有三个神级快捷键：

| 快捷键 | 作用 |
|---|---|
| `Ctrl+R` | 模糊搜索历史命令，比狂按 ↑ 快得多 |
| `Ctrl+T` | 模糊搜索当前目录文件，选中后路径直接插到命令行 |
| `Alt+C` | 模糊搜索子目录并 cd 进去 |

### 二进制安装方法（apt 用不了时）

有时 apt 不可用（比如 /var 不可写、没有 root），直接从 GitHub release 下二进制到家目录：

```bash
mkdir -p ~/.local/bin ~/.fzf/shell

# fzf
curl -sL -o /tmp/fzf.tgz https://github.com/junegunn/fzf/releases/download/v0.74.4/fzf-0.74.4-linux_amd64.tar.gz
cd /tmp && tar xzf fzf.tgz --no-same-owner && mv fzf ~/.local/bin/

# fzf 的 shell 集成脚本
curl -sL -o ~/.fzf/shell/key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/v0.74.4/shell/key-bindings.zsh
curl -sL -o ~/.fzf/shell/completion.zsh   https://raw.githubusercontent.com/junegunn/fzf/v0.74.4/shell/completion.zsh

# zoxide
curl -sL -o /tmp/zoxide.tgz https://github.com/ajeetdsouza/zoxide/releases/download/v0.10.0/zoxide-0.10.0-x86_64-unknown-linux-musl.tar.gz
cd /tmp && tar xzf zoxide.tgz --no-same-owner && mv zoxide ~/.local/bin/

chmod +x ~/.local/bin/fzf ~/.local/bin/zoxide
```

注意 `tar` 要加 `--no-same-owner`，否则在非 root 环境解压会因为无法改文件属主而失败。

## 五、踩过的坑

### 1. `~/.local/bin` 必须排在插件加载之前

这是个隐蔽的顺序坑。如果把 `export PATH="$HOME/.local/bin:$PATH"` 写在 plugins 后面，oh-my-zsh 的 zoxide 插件加载时找不到命令，会报：

```
[oh-my-zsh] zoxide not found, please install it from ...
```

**正确顺序**：PATH → plugins → `source $ZSH/oh-my-zsh.sh`。

### 2. zsh-syntax-highlighting 必须是最后一个插件

它给命令行上色，如果后面还加载了别的插件，着色会被覆盖。

### 3. conda 初始化要用 shell.zsh

`.zshrc` 里 conda 那段如果用 `shell.bash`，在 zsh 里属于错配（虽然 conda 的 hook 里有 ZSH 分支勉强能跑）。正确写法：

```zsh
. "/home/f/anaconda3/etc/profile.d/conda.sh"
```

### 4. 末尾的 compinit 不能删

oh-my-zsh 内部跑过一次 `compinit`，但那是在加载插件**之前**，覆盖不到 zsh-completions 提供的补全规则。所以文件末尾要再跑一次：

```zsh
autoload -U compinit && compinit -u
```

### 5. LD_LIBRARY_PATH 拼接别留空冒号

```zsh
# 错：变量为空时开头会多一个冒号，等于把当前目录加进搜索路径
export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH"

# 对
export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

### 6. PATH 去重

反复 `source ~/.zshrc` 会让 PATH 越叠越长。加一行让它自动去重：

```zsh
typeset -U path cdpath fpath manpath
```

## 六、完整配置

精简版 `.zshrc` 结构（按加载顺序）：

```zsh
# 1. powerlevel10k 即时提示（必须在最顶部）

# 2. PATH 基础（必须在插件之前）
export PATH="$HOME/.local/bin:$PATH"
typeset -U path cdpath fpath manpath

# 3. oh-my-zsh 设置
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# 4. 插件（语法高亮必须最后）
plugins=(
  git sudo extract colored-man-pages command-not-found history-substring-search
  docker docker-compose pip python
  zoxide zsh-completions fzf-tab
  zsh-autosuggestions zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# 5. 环境变量（CUDA / Docker / EDITOR）

# 6. 第三方初始化（conda / nvm / ROS / autojump / fzf）

# 7. 补全系统
autoload -U compinit && compinit -u
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# 8. 历史命令设置

# 9. 别名

# 10. p10k 外观配置
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

## 七、快捷键速查

| 按键 | 作用 |
|---|---|
| `Ctrl+R` | 模糊搜索历史命令 |
| `Ctrl+T` | 搜索文件并插入路径 |
| `Alt+C` | 搜索目录并进入 |
| `Tab` | 模糊搜索补全项 |
| `↑`（有前缀时） | 只翻匹配该前缀的历史 |
| `→` | 采用灰色提示的命令 |
| 连按两次 `Esc` | 给上条命令补 sudo |
| `z 关键词` | 跳转常用目录 |
| `x 文件名` | 解压任意格式 |

---

配这一套花了点时间，但每天能省下的敲键次数是实实在在的。尤其是 `Ctrl+R` 和 `z`，用习惯之后回不去。
