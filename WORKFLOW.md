# 写文章 → 发布 的完整流程

仓库是**公开**的，`source/` 下写的每个字、每次 commit 的信息都等于发表。流程按这个走，不会出事。

---

## 一、写一篇新文章

```bash
cd ~/code/my-blog
hexo new "文章标题"
```

会在 `source/_posts/` 生成同名 `.md`，front-matter 已按模板填好：

```yaml
---
title: 文章标题
categories:
  - 机器学习        # 机器学习 / 大模型 / 计算机视觉 / Linux / 效率工具
tags:
  -                # 写具体技术点：LoRA、PyTorch、CUDA、zsh
---

<!-- more -->   <!-- 这一行以上会作为首页摘要 -->
```

然后编辑：

```bash
nvim "source/_posts/文章标题.md"      # 或用你顺手的编辑器
```

**几个规矩**

- `abbrlink` 不用手写，第一次 `hexo generate` 会自动生成并写回 front-matter，之后改标题链接也不变。
- 文章封面不指定就用 `source/img/cover-1/2/3.png` 随机一张。想指定就在 front-matter 加 `cover: /img/xxx.png`。
- 配图放 `source/img/`，正文引用 `/img/xxx.png`。**别用外链图床**，境外图床国内加载不出来。
- 首页摘要靠 `<!-- more -->` 分割，不写会把全文堆在首页。
- 草稿不想公开发，用 `hexo new draft "标题"`，存在 `source/_drafts/`，不会进首页。要预览加 `--draft` 参数。

---

## 二、本地预览

```bash
hexo server          # 然后开 http://localhost:4000
```

改文件会自动重建，刷新即可。确认没问题再发。

---

## 三、发布（一条命令）

```bash
bash publish.sh "提交信息"
```

这条命令依次干四件事，**任何一步失败都会停**：

1. **隐私自查** → `check-privacy.sh` 扫敏感词和真实个人信息，命中就中断
2. **构建** → `hexo clean && hexo generate`
3. **提交推送** → `git add / commit / push`，GitHub Actions 自动部署
4. **推给搜索引擎** → IndexNow 提交全站 URL（Bing / Yandex / Seznam / Naver）

> Google 不吃 IndexNow，它靠 Search Console 里提交的 sitemap 自然抓取，不用管。

### 隐私自查在防什么

词表在 **`~/.blog-privacy-words`**（家目录，不进 git），检查三类：

- 词表里的敏感词
- 疑似手机号（1 开头的 11 位数字）
- 疑似真实邮箱（排除 noreply）

命中会打印文件名+行号并中断发布。**确认是误报**就把那个词从 `~/.blog-privacy-words` 删掉，别绕过检查直接 git push。

---

## 四、发布后

```bash
# 确认部署完成（看到新文章标题说明上线了）
curl -s https://fhj-id.github.io/ | grep -o "文章标题"

# 确认推送真的到了远端（push 报 408 多半是假失败）
git fetch && git status -sb
```

1-2 分钟生效。站点地址：https://fhj-id.github.io

---

## 五、常见情况处理

| 情况 | 怎么办 |
|---|---|
| `git push` 长时间不动 | git 已配好走 Clash 代理（`127.0.0.1:7897`），先确认 Clash Verge 在跑 |
| push 报 `HTTP 408 / 远端意外挂断` | 多半是假失败，用 `git fetch && git status -sb` 确认，一致就不用管 |
| 改配置没生效 | butterfly 版本升级会改键名，对照 `node_modules/hexo-theme-butterfly/_config.yml` 查，写错不报错只是静默失效 |
| 想撤回一篇文章 | 删掉 `source/_posts/xxx.md` 再跑一次 `publish.sh` |
| 改了标题 | 直接改，`abbrlink` 不变，URL 不受影响 |

---

## 六、发布前自己过一遍

- [ ] 有没有提到具体单位、部门、地域、班组或同事
- [ ] 有没有暴露具体工作场景的定位信息
- [ ] 有没有真实姓名、手机号、私人邮箱
- [ ] 配图里有没有截到终端里的用户名、主机名、内网 IP、路径
- [ ] 命令示例里的路径有没有夹带个人目录结构

不确定就按脱敏写法：「某次现场设备调试」「这台机器上的部署过程」。
