# از یک تصویر سبک استفاده می‌کنیم
FROM alpine:latest

# ابزارهای لازم را نصب می‌کنیم
RUN apk update && apk add --no-cache wget tar

# دانلود و نصب mtg در مسیر صحیح
RUN wget -q -O /tmp/mtg.tar.gz \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /usr/local/bin/ mtg-linux-amd64 \
    && mv /usr/local/bin/mtg-linux-amd64 /usr/local/bin/mtg \
    && chmod +x /usr/local/bin/mtg \
    && rm /tmp/mtg.tar.gz

# یک فایل کانفیگ ساده ایجاد می‌کنیم
RUN echo 'bind-to = "0.0.0.0:$PORT"' > /config.toml.template
RUN echo 'secret = "$SECRET"' >> /config.toml.template

# اسکریپت شروع که متغیرها را جایگزین می‌کند
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "جایگزینی متغیرهای محیطی در کانفیگ..."' >> /start.sh && \
    echo 'envsubst < /config.toml.template > /config.toml' >> /start.sh && \
    echo 'echo "آماده‌سازی پروکسی با سکرت ارائه شده..."' >> /start.sh && \
    echo 'exec mtg run /config.toml' >> /start.sh && \
    chmod +x /start.sh

# Railway پورت را خودش مدیریت می‌کند
EXPOSE $PORT

CMD ["/start.sh"]
