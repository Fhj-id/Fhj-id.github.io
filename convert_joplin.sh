#!/bin/bash
# 将 Joplin 导出的 Markdown 转换为 Hexo 格式
# 用法：./convert_joplin.sh /path/to/joplin_export/*.md

JOPLIN_EXPORT_DIR="$HOME/Documents/joplin_export"  # Joplin导出目录
HEXO_POSTS_DIR="$HOME/my-blog/source/_posts"       # Hexo文章目录

# 如果传入了参数，使用参数指定的文件；否则处理导出目录下所有md文件
if [ "$1" != "" ]; then
    FILES=("$1")
else
    FILES=("$JOPLIN_EXPORT_DIR"/*.md)
fi

for file in "${FILES[@]}"; do
    # 跳过不存在的文件
    [ -f "$file" ] || continue
    
    filename=$(basename "$file")
    echo "📝 正在转换: $filename"
    
    # 提取Joplin的title和created日期
    title=$(grep "^title:" "$file" | head -1 | sed 's/title: //')
    created_date=$(grep "^created:" "$file" | head -1 | sed 's/created: //' | sed 's/Z$//')
    updated_date=$(grep "^updated:" "$file" | head -1 | sed 's/updated: //' | sed 's/Z$//')
    
    # 如果提取不到created，使用当前时间
    if [ -z "$created_date" ]; then
        created_date=$(date '+%Y-%m-%d %H:%M:%S')
    fi
    
    # 检查是否有加密标签（你可以自定义标签名）
    ENCRYPTED=false
    if grep -q "#加密" "$file"; then
        ENCRYPTED=true
        echo "  🔐 检测到加密标签"
    fi
    
    # 构建新的Front-matter
    {
        echo "---"
        echo "title: $title"
        echo "date: $created_date"
        if [ -n "$updated_date" ]; then
            echo "updated: $updated_date"
        fi
        echo "categories:"
        echo "  - 技术笔记"
        echo "tags:"
        echo "  - 待分类"
        if [ "$ENCRYPTED" = true ]; then
            echo "password: 你的强密码"  # 替换成你实际的密码
            echo "abstract: 这是一篇加密文章"
            echo "message: 请输入密码查看"
        fi
        echo "---"
        echo ""
    } > "$HEXO_POSTS_DIR/$filename"
    
    # 跳过原文件的Front-matter（--- ... ---），只追加正文
    sed -n '/^---$/,/^---$/d; /^---$/d; p' "$file" >> "$HEXO_POSTS_DIR/$filename"
    
    echo "✅ 转换完成: $filename -> $HEXO_POSTS_DIR/$filename"
done

echo "🎉 所有文章转换完成！"
echo "请运行 ./publish.sh 发布"
