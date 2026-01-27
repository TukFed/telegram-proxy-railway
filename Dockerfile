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

# اسکریپت راه‌اندازی اصلاح شده
RUN cat > /start.sh << 'EOF'
#!/bin/sh
set -e

echo "=== MTProto Proxy on Railway ==="

# تولید سکرت FakeTLS - سینتکس صحیح نسخه 2
if [ -z "$SECRET" ]; then
    # فقط نام دامنه رو می‌دیم، خودش ee تولید می‌کنه
    SECRET=$(/usr/local/bin/mtg generate-secret cloudflare.com)
    echo "🆕 Secret جدید تولید شد: $SECRET"
else
    echo "🔑 Secret از متغیر محیطی: $SECRET"
fi

# چک کردن اینکه secret خالی نباشه
if [ -z "$SECRET" ]; then
    echo "❌ خطا: Secret تولید نشد!"
    exit 1
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

# ساخت لینک صحیح
LINK="https://t.me/proxy?server=${SERVER}&port=${PORT}&secret=${SECRET}"
echo ""
echo "📱 لینک اتصال تلگرام:"
echo "$LINK"
echo ""

# چک کردن اینکه secret با ee شروع میشه (FakeTLS)
case "$SECRET" in
    ee*)
        echo "✅ Secret به درستی با 'ee' شروع می‌شود (FakeTLS فعال)"
        ;;
    *)
        echo "⚠️  توجه: Secret با 'ee' شروع نمی‌شود. در حال تولید دوباره..."
        SECRET=$(/usr/local/bin/mtg generate-secret cloudflare.com)
        echo "🔑 Secret جدید: $SECRET"
        ;;
esac

echo ""
echo "🚀 در حال اجرای پروکسی..."
echo ""

# اجرای پروکسی
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"]
