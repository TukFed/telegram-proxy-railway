FROM alpine:latest

RUN apk update && apk add curl tar

# دانلود مستقیم mtg
RUN wget -q -O /usr/local/bin/mtg \
    https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg_2.1.7_linux_amd64.tar.gz \
    && tar -xzf /usr/local/bin/mtg -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg

# ایجاد اسکریپت اجرا
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting MTProto Proxy..."' >> /start.sh && \
    echo 'SECRET=$(mtg generate-secret --hex google.com)' >> /start.sh && \
    echo 'DOMAIN=${RAILWAY_STATIC_URL:-proxy.railway.app}' >> /start.sh && \
    echo 'PORT=${PORT:-8080}' >> /start.sh && \
    echo 'echo "Secret: $SECRET"' >> /start.sh && \
    echo 'echo "Link: https://t.me/proxy?server=$DOMAIN&port=443&secret=$SECRET"' >> /start.sh && \
    echo 'exec mtg simple-run "0.0.0.0:$PORT" "$SECRET"' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
