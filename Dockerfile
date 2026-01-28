FROM python:3.9-alpine

RUN apk add --no-cache git gcc musl-dev

# نصب MTProto Proxy اصلی
RUN git clone https://github.com/TelegramMessenger/MTProxy.git /mtproxy && \
    cd /mtproxy && \
    make && \
    mv /mtproxy/objs/bin/mtproto-proxy /usr/local/bin/

ENV PORT=8080
ENV SECRET=""
ENV TAG=""

WORKDIR /mtproxy

RUN cat > /start.sh << 'EOF'
#!/bin/sh
if [ -z "$SECRET" ]; then
    SECRET=$(head -c 16 /dev/urandom | xxd -ps)
    echo "🆕 Secret: $SECRET"
fi

echo "=========================================="
echo "🌐 Server: ${RAILWAY_TCP_PROXY_DOMAIN:-localhost}"
echo "🔌 Port: 17782"
echo "🔑 Secret: $SECRET"
echo "=========================================="
echo "📱 https://t.me/proxy?server=${RAILWAY_TCP_PROXY_DOMAIN:-localhost}&port=17782&secret=${SECRET}"
echo "=========================================="

exec /usr/local/bin/mtproto-proxy \
    -u nobody \
    -p 8888 \
    -H $PORT \
    -S $SECRET \
    --allow-skip-dh \
    --bind-to 0.0.0.0 \
    --aes-pwd /etc/passwd \
    --proxy-tag ${TAG:-00000000000000000000000000000000}
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"]
