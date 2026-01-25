#!/bin/bash

echo "========================================"
echo "🚀 MTProto Proxy for Telegram"
echo "📡 Hosted on Railway"
echo "========================================"

# تنظیمات پیش‌فرض
PORT=${PORT:-8080}
DOMAIN=${RAILWAY_STATIC_URL:-"your-proxy.up.railway.app"}

# تولید کلید اگر وجود ندارد - با متغیر SECRET (نه SECRET_KEY)
if [ -z "$SECRET" ]; then
    echo "🔑 Generating new secret key..."
    # روش صحیح تولید کلید برای mtg v2
    SECRET=$(openssl rand -hex 16 | xxd -r -p | base64 | tr -d '\n=')
    echo "✅ Secret key generated!"
    echo "🔐 Secret: $SECRET"
    echo ""
    export SECRET
else
    echo "🔑 Using provided secret key"
    echo ""
fi

# نمایش اطلاعات
echo "📊 Proxy Information:"
echo "• Domain: $DOMAIN"
echo "• Port: $PORT"
echo "• Secret starts with: ${SECRET:0:20}..."
echo ""

# بررسی mtg
if [ ! -f /usr/local/bin/mtg ]; then
    echo "❌ ERROR: mtg not found!"
    exit 1
fi

# نمایش ورژن
echo "🔧 mtg version:"
mtg version
echo ""

# ساخت لینک‌ها
if [ ! -z "$SECRET" ]; then
    echo "📱 Telegram Links:"
    echo ""
    echo "🌐 For browser:"
    echo "https://t.me/proxy?server=$DOMAIN&port=443&secret=$SECRET"
    echo ""
    echo "📲 For Telegram app:"
    echo "tg://proxy?server=$DOMAIN&port=443&secret=$SECRET"
    echo ""
fi

echo "🔄 Starting proxy on port $PORT..."
echo "========================================"

# اجرای پروکسی
exec mtg run \
    --bind "0.0.0.0:$PORT" \
    --secret "$SECRET" \
    --cloak-port 443 \
    --stats ":8081" \
    --verbose
