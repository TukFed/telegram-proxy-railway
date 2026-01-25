#!/bin/bash

echo "========================================"
echo "🚀 MTProto Proxy for Telegram"
echo "📡 Hosted on Railway"
echo "========================================"

# تنظیمات پیش‌فرض
PORT=${PORT:-8080}
DOMAIN=${RAILWAY_STATIC_URL:-"your-proxy.up.railway.app"}

# تولید کلید اگر وجود ندارد
if [ -z "$SECRET_KEY" ]; then
    echo "🔑 Generating new secret key..."
    # روش صحیح تولید کلید برای mtg v2
    SECRET_KEY=$(openssl rand -hex 32 | xxd -r -p | base64)
    echo "✅ Secret key generated!"
    echo ""
fi

# نمایش اطلاعات
echo "📊 Proxy Information:"
echo "• Domain: $DOMAIN"
echo "• Port: $PORT"
echo "• Secret: ${SECRET_KEY:0:20}..."
echo ""

# بررسی mtg
if [ ! -f /usr/local/bin/mtg ]; then
    echo "❌ ERROR: mtg not found!"
    exit 1
fi

# نمایش ورژن
echo "🔧 mtg version:"
/usr/local/bin/mtg version
echo ""

# ساخت لینک‌ها
if [ ! -z "$SECRET_KEY" ]; then
    echo "📱 Telegram Links:"
    echo "• Web: https://t.me/proxy?server=$DOMAIN&port=443&secret=$SECRET_KEY"
    echo "• App: tg://proxy?server=$DOMAIN&port=443&secret=$SECRET_KEY"
    echo ""
fi

echo "🔄 Starting proxy on port $PORT..."
echo "   Using secret: ${SECRET_KEY:0:20}..."
echo "========================================"

# اجرای پروکسی
exec /usr/local/bin/mtg run \
    --bind "0.0.0.0:$PORT" \
    --secret "$SECRET_KEY" \
    --cloak-port 443
