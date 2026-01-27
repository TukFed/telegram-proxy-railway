# از یک تصویر سبک استفاده می‌کنیم
FROM alpine:latest

# ابزارهای لازم را نصب می‌کنیم
RUN apk update && apk add --no-cache wget tar

# دانلود و نصب mtg
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /usr/local/bin/ mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm /tmp/mtg.tar.gz

# ایجاد اسکریپت راه‌اندازی
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "=== MTProxy Auto-Setup ==="' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# تولید سکرت جدید (اختیاری: میتوانید یک سکرت ثابت هم بدهید)' >> /start.sh && \
    echo 'export SECRET=$(/usr/local/bin/mtg generate-secret --hex google.com)' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# دریافت آدرس عمومی (اگر Railway باشد)' >> /start.sh && \
    echo 'if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then' >> /start.sh && \
    echo '    SERVER="$RAILWAY_PUBLIC_DOMAIN"' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '    # اگر دامنه Railway نداریم، از IP داخلی استفاده می‌کنیم' >> /start.sh && \
    echo '    SERVER="$(hostname -i)"' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# تنظیم پورت (Railway پورت را در متغیر PORT قرار می‌دهد)' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# نمایش اطلاعات برای کاربر' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "✅ پروکسی شما آماده است!"' >> /start.sh && \
    echo 'echo "🔑 Secret: $SECRET"' >> /start.sh && \
    echo 'echo "🌐 Server: $SERVER"' >> /start.sh && \
    echo 'echo "🔌 Port: $PORT"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "📱 لینک مستقیم تلگرام:"' >> /start.sh && \
    echo 'echo "https://t.me/proxy?server=$SERVER&port=443&secret=$SECRET"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# اجرای پروکسی' >> /start.sh && \
    echo 'exec /usr/local/bin/mtg simple-run "0.0.0.0:$PORT" "$SECRET"' >> /start.sh && \
    chmod +x /start.sh

# Railway پورت را خودش مدیریت می‌کند
EXPOSE $PORT

CMD ["/start.sh"]
