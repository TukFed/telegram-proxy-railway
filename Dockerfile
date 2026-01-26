FROM alpine:latest

# نصب ابزارها
RUN apk update && apk add --no-cache \
    curl \
    bash \
    tar \
    gzip \
    openssl \
    python3

# دانلود mtg
RUN curl -sL "https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz" \
    | tar -xz -C /usr/local/bin/ --strip-components=1 mtg-2.1.7-linux-amd64/mtg \
    && chmod +x /usr/local/bin/mtg

# ایجاد اسکریپت Python برای تولید کلید صحیح
RUN echo '#!/usr/bin/env python3
import secrets
import base64

# تولید کلید به فرمت صحیح برای mtg
# باید با 0xee شروع شود (برای پروکسی معمولی)
def generate_secret():
    # 16 بایت تصادفی
    random_bytes = secrets.token_bytes(16)
    # تبدیل به hex و اضافه کردن 0xee به ابتدا
    hex_bytes = "ee" + random_bytes.hex()
    # یا برای دامنه خاص:
    # hex_bytes = "dd" + random_bytes.hex() + "google.com".encode().hex()
    return hex_bytes

secret = generate_secret()
print(secret)
' > /generate_secret.py

# ایجاد اسکریپت اجرا
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "🚀 Starting MTProto Proxy..."' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# تولید کلید صحیح' >> /start.sh && \
    echo 'if [ -z "$SECRET" ]; then' >> /start.sh && \
    echo '    echo "🔑 Generating secret key..."' >> /start.sh && \
    echo '    # روش ۱: با پایتون (توصیه می‌شود)' >> /start.sh && \
    echo '    if command -v python3 > /dev/null; then' >> /start.sh && \
    echo '        SECRET=$(python3 /generate_secret.py)' >> /start.sh && \
    echo '    else' >> /start.sh && \
    echo '        # روش ۲: با openssl' >> /start.sh && \
    echo '        RANDOM_HEX=$(openssl rand -hex 16)' >> /start.sh && \
    echo '        SECRET="ee${RANDOM_HEX}"' >> /start.sh && \
    echo '    fi' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "✅ Secret: $SECRET"' >> /start.sh && \
    echo 'echo "🌐 Domain: ${RAILWAY_STATIC_URL}"' >> /start.sh && \
    echo 'echo "📱 Link: https://t.me/proxy?server=${RAILWAY_STATIC_URL}&port=443&secret=$SECRET"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# اجرای پروکسی' >> /start.sh && \
    echo 'exec mtg simple-run "0.0.0.0:$PORT" "$SECRET"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
