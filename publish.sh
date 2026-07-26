#!/bin/bash
# Hexo 一键发布脚本（简洁输出版）

echo "🔨 正在构建博客..."

# 执行 hexo 清理和生成，将标准输出（INFO）重定向到 /dev/null，只保留错误输出
if hexo clean > /dev/null 2>&1 && hexo generate > /dev/null 2>&1; then
    echo "✅ 构建成功"
else
    echo "❌ 构建失败，请查看上方错误信息"
    exit 1
fi

# Git 操作，静默模式
git add . > /dev/null 2>&1

if [ "$1" != "" ]; then
    git commit -m "$1" > /dev/null 2>&1
else
    git commit -m "📝 更新博客内容 $(date '+%Y-%m-%d %H:%M:%S')" > /dev/null 2>&1
fi

# 推送，只显示进度条（去掉 -v 即可）
echo "🚀 正在推送到 GitHub..."
git push --quiet

echo "✅ 发布完成！等待 1-2 分钟访问 https://Fhj-id.github.io"
