FROM alpine:latest

RUN apk update && apk add --no-cache curl tar

# دانلود mtg
RUN wget -q -O /tmp/mtg.tar.gz https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz \
    && tar -xzf /tmp/mtg.tar.gz -C /tmp/ \
    && mv /tmp/mtg-2.1.7-linux-amd64/mtg /usr/local/bin/ \
    && chmod +x /usr/local/bin/mtg \
    && rm -rf /tmp/mtg*

# تست mtg
RUN mtg --version

# کپی اسکریپت run.sh
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# اجرا
CMD ["/app/run.sh"]
