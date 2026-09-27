#!/usr/bin/env python3
"""发新文章后主动推送 URL 给支持 IndexNow 的搜索引擎（Bing / Yandex / Seznam / Naver）。

用法：
    python3 push-indexnow.py            # 推送 public/sitemap.xml 里的全部 URL
    python3 push-indexnow.py <url> ...  # 只推送指定 URL

注意：Google 不参与 IndexNow，Google 侧靠 Search Console 提交的 sitemap 自然抓取。
"""
import json
import os
import re
import sys
import urllib.request

KEY = "4be0fe51113a965be6bbac30d30146dc"
HOST = "fhj-id.github.io"
SITEMAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "public", "sitemap.xml")


def collect_urls():
    if len(sys.argv) > 1:
        return sys.argv[1:]
    if not os.path.exists(SITEMAP):
        print("找不到 public/sitemap.xml，请先运行 hexo generate")
        sys.exit(1)
    xml = open(SITEMAP, encoding="utf-8").read()
    return re.findall(r"<loc>([^<]+)</loc>", xml)


def main():
    urls = collect_urls()
    if not urls:
        print("没有可推送的 URL")
        return

    payload = {
        "host": HOST,
        "key": KEY,
        "keyLocation": f"https://{HOST}/{KEY}.txt",
        "urlList": urls,
    }
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(
        "https://api.indexnow.org/IndexNow",
        data=body,
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            print(f"IndexNow: HTTP {r.status} | 已提交 {len(urls)} 个 URL")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", "ignore")[:200]
        print(f"IndexNow: HTTP {e.code} | {detail}")
        sys.exit(1)
    except Exception as e:
        print(f"IndexNow 推送失败: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
