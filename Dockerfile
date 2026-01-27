FROM alpine:latest

# نصب ابزارهای لازم
RUN apk add --no-cache wget tar openssl xxd

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

echo "=========================================="
echo "   MTProto Proxy - Railway"
echo "=========================================="

# تولید Secret FakeTLS (اگر تنظیم نشده باشه)
if [ -z "$SECRET" ]; then
    echo "🔄 در حال تولید سکرت FakeTLS..."
    
    # 16 بایت رندوم (32 کاراکتر هگز)
    RANDOM_HEX=$(openssl rand -hex 16)
    
    # تبدیل دامنه به هگز (cloudflare.com)
    DOMAIN_HEX=$(printf 'cloudflare.com' | xxd -p | tr -d '\n')
    
    # ساخت سکرت: ee + رندوم + دامنه
    SECRET="ee${RANDOM_HEX}${DOMAIN_HEX}"
    
    echo "✅ سکرت جدید: $SECRET"
else
    echo "🔑 استفاده از سکرت موجود: $SECRET"
fi

# چک کردن فرمت صحیح (باید با ee شروع بشه)
if [ "${SECRET#ee}" = "$SECRET" ]; then
    echo "❌ خطا: سکرت باید با 'ee' شروع بشه (FakeTLS)"
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
    SERVER="0.0.0.0"
    echo "⚠️  دامنه یافت نشد، استفاده از 0.0.0.0"
fi

echo ""
echo "🌐 Server: $SERVER"
echo "🔌 Port: $PORT"
echo ""

# نمایش لینک اتصال
echo "📱 لینک تلگرام:"
echo "https://t.me/proxy?server=${SERVER}&port=${PORT}&secret=${SECRET}"
echo ""
echo "=========================================="

# اجرای پروکسی (مهم: exec برای جلویری از exit)
exec /usr/local/bin/mtg simple-run "0.0.0.0:${PORT}" "${SECRET}"
EOF

RUN chmod +x /start.sh

# Railway پورت رو خودش مدیریت می‌کنه
EXPOSE ${PORT}

CMD ["/start.sh"]
