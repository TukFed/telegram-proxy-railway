#!/bin/bash

echo "========================================"
echo "🚀 MTProto Proxy برای تلگرام"
echo "========================================"

# اگر کلید وجود نداشت، بساز
if [ -z "$SECRET" ]; then
    echo "🔑 ساخت کلید جدید..."
    SECRET=$(openssl rand -hex 16 | base64 | tr -d '=' | tr '+/' '-_')
    echo "✅ کلید ساخته شد!"
    echo "🔐 کلید شما: $SECRET"
    echo "⚠️ این کلید را ذخیره کن!"
fi

echo ""
echo "📊 اطلاعات پروکسی:"
echo "• دامنه: ${RAILWAY_STATIC_URL:-your-domain.up.railway.app}"
echo "• پورت: 443"
echo "• کلید: $SECRET"
echo ""

# ساخت لینک تلگرام
DOMAIN="${RAILWAY_STATIC_URL:-your-domain.up.railway.app}"
TG_LINK="https://t.me/proxy?server=${DOMAIN}&port=443&secret=${SECRET}"
DIRECT_LINK="tg://proxy?server=${DOMAIN}&port=443&secret=${SECRET}"

echo "📱 لینک پروکسی:"
echo "$TG_LINK"
echo ""
echo "📲 لینک مستقیم (برای موبایل):"
echo "$DIRECT_LINK"
echo ""
echo "========================================"
echo "🔄 در حال راه‌اندازی پروکسی..."
echo "========================================"

# اجرای پروکسی
exec mtg run \
    --bind "0.0.0.0:$PORT" \
    --adapter "mem" \
    --cloak-port 443 \
    "$SECRET"