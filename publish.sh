#!/bin/bash
# Hexo 一键发布脚本

VERBOSE=true  # 改为 true 可输出全部日志

# 根据 VERBOSE 决定输出重定向
if [ "$VERBOSE" = true ]; then
    HEXO_OUTPUT=""
    GIT_OUTPUT=""
else
    HEXO_OUTPUT="> /dev/null 2>&1"
    GIT_OUTPUT="> /dev/null 2>&1"
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
git push --quiet

echo "✅ 发布完成！等待 1-2 分钟访问 https://Fhj-id.github.io"
