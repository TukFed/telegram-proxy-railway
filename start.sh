#!/bin/sh

set -e

echo "========================================"
echo "🚀 TELEGRAM MTProto PROXY - ENHANCED"
echo "========================================"

# تنظیمات Railway
DOMAIN="${RAILWAY_STATIC_URL}"
PORT="${PORT:-8080}"
IP_ADDRESS="$(curl -s ifconfig.me)"

# تولید یا استفاده از secret
if [ -n "${SECRET_KEY}" ]; then
    SECRET="${SECRET_KEY}"
    echo "✅ Using pre-configured secret"
else
    # تولید secret FakeTLS
    SECRET=$(mtg generate-secret --hex "${DOMAIN:-telegram.org}")
    echo "⚠️  New secret generated (save it for reuse):"
fi

# نمایش اطلاعات
echo ""
echo "📊 SERVER INFORMATION:"
echo "• Domain: ${DOMAIN}"
echo "• IP Address: ${IP_ADDRESS}"
echo "• Internal Port: ${PORT}"
echo "• Public Port: 443 (HTTPS via Railway)"
echo "• Protocol: FakeTLS"
echo ""

# نمایش secret
echo "🔑 SECRET KEY:"
echo "${SECRET}"
echo ""

# نمایش لینک‌های تلگرام
echo "📱 TELEGRAM LINKS:"
echo ""
echo "1. DIRECT LINK:"
echo "tg://proxy?server=${DOMAIN}&port=443&secret=${SECRET}"
echo ""
echo "2. WEB LINK:"
echo "https://t.me/proxy?server=${DOMAIN}&port=443&secret=${SECRET}"
echo ""
echo "3. WITH IP (alternative):"
echo "tg://proxy?server=${IP_ADDRESS}&port=443&secret=${SECRET}"
echo ""
echo "========================================"
echo "⚙️  Starting enhanced MTProto proxy..."
echo "========================================"

# اجرای پروکسی با تنظیمات پیشرفته
exec mtg run /app/config.toml
