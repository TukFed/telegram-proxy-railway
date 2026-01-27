FROM alpine:latest

# نصب ابزارهای لازم
RUN apk add --no-cache wget tar

# دانلود mtg نسخه 2.1.7
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-*/mtg /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/*

# اسکریپت راه‌اندازی
RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

echo "=== MTProto Proxy on Railway ==="

# تولید سکرت FakeTLS (شروع با ee)
if [ -z "$SECRET" ]; then
    SECRET=$(/usr/local/bin/mtg generate-secret tls -c www.cloudflare.com | tr -d '\n')
    echo "🆕 Secret جدید تولید شد: $SECRET"
else
    echo "🔑 Secret از متغیر محیطی: $SECRET"
fi

# پورت Railway (پیش‌فرض 8080)
PORT=${PORT:-8080}

# دامنه Railway
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    SERVER="$RAILWAY_PUBLIC_DOMAIN"
elif [ -n "$RAILWAY_STATIC_URL" ]; then
    SERVER=$(echo "$RAILWAY_STATIC_URL" | sed 's|https://||')
else
    SERVER="localhost"
fi

echo "🌐 Server: $SERVER"
echo "🔌 Port: $PORT"

# ساخت لینک صحیح (بدون space)
LINK="https://t.me/proxy?server=${SERVER}&port=${PORT}&secret=${SECRET}"
echo ""
echo "📱 لینک اتصال تلگرام:"
echo "$LINK"
echo ""
echo "⚠️  برای اتصال، Secret باید با 'ee' شروع بشه (FakeTLS)"
echo ""

# اجرای پروکسی روی 0.0.0.0
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

# Railway خودش PORT رو مدیریت می‌کنه
CMD ["/start.sh"]
