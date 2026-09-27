#!/bin/bash
# Hexo 一键发布脚本

VERBOSE=false  # 改为 true 可输出全部日志

# hexo 装在项目本地的 node_modules 里，全局命令不一定存在
# 不加这行会报 "hexo: command not found"
export PATH="$PWD/node_modules/.bin:$PATH"

# 根据 VERBOSE 决定输出重定向
if [ "$VERBOSE" = true ]; then
    HEXO_OUTPUT=""
    GIT_OUTPUT=""
else
    HEXO_OUTPUT="> /dev/null 2>&1"
    GIT_OUTPUT="> /dev/null 2>&1"
fi

# 发布前隐私自查（命中敏感词直接中断，别把不该发的发出去）
if ! bash check-privacy.sh; then
    echo "❌ 发布已取消"
    exit 1
fi

echo "🔨 正在构建博客..."

# 使用变量控制输出
if eval "hexo clean $HEXO_OUTPUT" && eval "hexo generate $HEXO_OUTPUT"; then
    echo "✅ 构建成功"
else
    echo "❌ 构建失败，请查看上方错误信息"
    exit 1
fi

eval "git add . $GIT_OUTPUT"

if [ "$1" != "" ]; then
    eval "git commit -m \"$1\" $GIT_OUTPUT"
else
    eval "git commit -m \"📝 更新博客内容 $(date '+%Y-%m-%d %H:%M:%S')\" $GIT_OUTPUT"
fi

echo "🚀 正在推送到 GitHub..."
# git push 偶发报 408 但数据其实已到远端，报错时不要慌，用 git fetch && git status -sb 确认
if git push --quiet; then
    echo "✅ 发布完成！等待 1-2 分钟访问 https://Fhj-id.github.io"
else
    echo "⚠️ 推送命令报错，先确认远端是否真的收到了：git fetch && git status -sb"
    exit 1
fi

# 主动推送给 Bing / Yandex 等（Google 不支持 IndexNow，走 sitemap 自然抓取）
# 失败不影响发布结果
python3 push-indexnow.py 2>&1 | sed 's/^/   /'
