#!/bin/bash

echo "========================================"
echo "🚀 STARTING MTProto Proxy"
echo "========================================"

# لاگ همه متغیرهای محیطی
echo "📋 Environment variables:"
echo "PORT: ${PORT:-not set}"
echo "RAILWAY_STATIC_URL: ${RAILWAY_STATIC_URL:-not set}"
echo "PWD: $(pwd)"
echo "PATH: $PATH"
echo ""

# بررسی وجود mtg
echo "🔍 Checking for mtg..."
if command -v mtg > /dev/null 2>&1; then
    echo "✅ mtg found at: $(which mtg)"
    echo "mtg version: $(mtg --version 2>/dev/null || echo 'cannot get version')"
else
    echo "❌ mtg NOT FOUND in PATH!"
    echo "Searching for mtg binary..."
    find / -name mtg -type f 2>/dev/null | head -10
    exit 1
fi

# تولید secret با استفاده از mtg
echo ""
echo "🔑 Generating secret..."
SECRET=$(mtg generate-secret --hex telegram.org)
echo "✅ Secret generated: $SECRET"
echo ""

# نمایش اطلاعات
DOMAIN="${RAILWAY_STATIC_URL:-proxy.up.railway.app}"
PORT="${PORT:-8080}"

echo "📊 Configuration:"
echo "• Bind: 0.0.0.0:$PORT"
echo "• Domain: $DOMAIN"
echo "• Secret: $SECRET"
echo ""

# ساخت لینک تلگرام
echo "📱 Telegram links:"
echo "1. tg://proxy?server=$DOMAIN&port=443&secret=$SECRET"
echo "2. https://t.me/proxy?server=$DOMAIN&port=443&secret=$SECRET"
echo ""

# شروع یک healthcheck ساده در پس‌زمینه
echo "🩺 Starting healthcheck server on port 8081..."
(
    while true; do
        echo -e "HTTP/1.1 200 OK\r\n\r\nMTProto Proxy OK" | nc -l -p 8081 -q 1 2>/dev/null || \
        sleep 1
    done
) &

# تست دستور mtg قبل از اجرا
echo "🧪 Testing mtg command..."
if mtg run --help > /dev/null 2>&1; then
    echo "✅ mtg command works"
else
    echo "❌ mtg command failed"
    echo "Trying to run mtg directly:"
    /usr/local/bin/mtg run --help || echo "Direct execution also failed"
fi

echo ""
echo "🔄 STARTING MTG PROXY..."
echo "========================================"

# اجرای mtg با تمام لاگ‌ها
exec mtg simple-run "0.0.0.0:$PORT" "$SECRET" 2>&1
