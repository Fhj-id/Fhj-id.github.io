#!/bin/bash
# Hexo 一键发布脚本

# 1. 清理并生成静态文件
echo "🔨 正在构建博客..."
hexo clean && hexo generate

# 2. 自动添加所有更改
git add .

# 3. 自动提交（支持自定义信息）
if [ "$1" != "" ]; then
    git commit -m "$1"
else
    git commit -m "📝 更新博客内容 $(date '+%Y-%m-%d %H:%M:%S')"
fi

# 4. 推送到GitHub（凭据缓存自动生效，无交互）
git push

echo "✅ 发布完成！等待1-2分钟访问 https://Fhj-id.github.io"
