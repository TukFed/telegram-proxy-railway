FROM alpine:latest

# نصب ابزارهای لازم
RUN apk add --no-cache wget tar openssl

# دانلود mtg نسخه 2.1.7
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz && \
    tar -xzf /tmp/mtg.tar.gz -C /tmp/ && \
    mv /tmp/mtg-*/mtg /usr/local/bin/mtg && \
    chmod +x /usr/local/bin/mtg && \
    rm -rf /tmp/*

# اسکریپت راه‌اندازی
RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

PORT=${PORT:-8080}

# تولید سکرت صحیح با prefix "dd" (Secure Mode)
# ساختار: dd + 32 کاراکتر hex
if [ -z "$SECRET" ]; then
    RANDOM_PART=$(openssl rand -hex 16)
    SECRET="dd${RANDOM_PART}"
    echo "✅ سکرت جدید تولید شد: $SECRET"
else
    echo "🔑 استفاده از سکرت تنظیم شده: $SECRET"
fi

# دریافت دامنه Railway
if [ -n "$RAILWAY_TCP_PROXY_DOMAIN" ]; then
    SERVER="$RAILWAY_TCP_PROXY_DOMAIN"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SERVER="$RAILWAY_PUBLIC_DOMAIN"
else
    SERVER="localhost"
fi

echo ""
echo "=========================================="
echo "   MTProto Proxy - Railway TCP"
echo "=========================================="
echo "🌐 Server: $SERVER"
echo "🔌 Internal Port: $PORT"
echo "🔌 External Port: 17782"
echo "🔑 Secret: $SECRET"
echo ""
echo "📱 لینک اتصال تلگرام:"
echo "https://t.me/proxy?server=${SERVER}&port=17782&secret=${SECRET}"
echo ""
echo "⚠️  مهم: حتماً از پورت 17782 (خارجی) استفاده کنید!"
echo "=========================================="
echo ""

# اجرای MTProto
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

# Railway پورت داخلی رو مدیریت می‌کنه
EXPOSE ${PORT}

CMD ["/start.sh"]
