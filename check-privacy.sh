#!/bin/bash
# 发布前隐私自查：扫描 source/ 与配置文件，命中敏感词或真实个人信息就中断发布。
# 词表放在 ~/.blog-privacy-words（家目录，不进 git），可自行增删。
# 用法：bash check-privacy.sh

WORDLIST="$HOME/.blog-privacy-words"
TARGETS="source _config.yml _config.butterfly.yml"

RED='\033[0;31m'; YEL='\033[0;33m'; GRN='\033[0;32m'; NC='\033[0m'

if [ ! -f "$WORDLIST" ]; then
    echo -e "${YEL}⚠ 未找到词表 $WORDLIST，跳过敏感词检查${NC}"
    exit 0
fi

# 去掉注释行和空行，拼成 grep -E 的正则
PATTERN=$(grep -v '^\s*#' "$WORDLIST" | grep -v '^\s*$' | sed 's/[[:space:]]*$//' | paste -sd'|' -)

if [ -z "$PATTERN" ]; then
    echo -e "${YEL}⚠ 词表为空，跳过检查${NC}"
    exit 0
fi

echo "🔍 隐私自查中..."

HITS=$(grep -rnE --include='*.md' --include='*.yml' --include='*.html' --include='*.txt' "$PATTERN" $TARGETS 2>/dev/null)

# 额外检查：疑似手机号（1 开头的 11 位数字）
PHONE=$(grep -rnE --include='*.md' --include='*.yml' '\b1[3-9][0-9]{9}\b' source _config.yml _config.butterfly.yml 2>/dev/null)

# 额外检查：疑似真实邮箱（排除 noreply / example）
MAIL=$(grep -rnE --include='*.md' --include='*.yml' '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' source _config.yml _config.butterfly.yml 2>/dev/null | grep -v 'noreply' | grep -v 'example.com')

FOUND=0

if [ -n "$HITS" ]; then
    echo -e "${RED}✗ 命中敏感词：${NC}"
    echo "$HITS" | head -20
    FOUND=1
fi

if [ -n "$PHONE" ]; then
    echo -e "${RED}✗ 疑似手机号：${NC}"
    echo "$PHONE" | head -10
    FOUND=1
fi

if [ -n "$MAIL" ]; then
    echo -e "${RED}✗ 疑似真实邮箱：${NC}"
    echo "$MAIL" | head -10
    FOUND=1
fi

if [ "$FOUND" = "1" ]; then
    echo
    echo -e "${RED}发布已中断。请修改后再发，或确认是误报后把该词从 $WORDLIST 移除。${NC}"
    exit 1
fi

echo -e "${GRN}✓ 隐私自查通过${NC}"
exit 0
