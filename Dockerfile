FROM alpine:3.17

LABEL maintainer="developer@mplx.eu"
LABEL org.opencontainers.image.source=https://github.com/mplx/mailarchive
LABEL org.opencontainers.image.description="simple mailarchive server"
LABEL org.opencontainers.image.licenses=MIT

ENV ALPINE_MIRROR_BASE="http://dl-cdn.alpinelinux.org"
ENV TZ="Europe/Vienna"

RUN \
    echo "Installing generic linux configuration..." && \
    echo $TZ > /etc/TZ &&\
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "${ALPINE_MIRROR_BASE}/alpine/v3.17/main" > /etc/apk/repositories && \
    echo "${ALPINE_MIRROR_BASE}/alpine/v3.17/community" >> /etc/apk/repositories && \
    apk update && \
    apk --no-cache --update upgrade && \
    apk add --no-cache --update bash ca-certificates curl git jq nano openssl tzdata patch && \
    echo "Installing project based configuration..." && \
    apk add --no-cache supervisor dovecot && \
    rm -f /etc/supervisord.conf && \
    addgroup -g 1000 vmail && \
    adduser -u 1000 -G vmail --gecos 'dovecot user' -D vmail && \
    rm -rf /etc/ssl/dovecot/* && \
    rm /etc/dovecot/conf.d/10-ssl.conf && \
    sed -Ei \
        -e 's,^#protocols = .+,protocols = imap,' \
        -e 's,^#?ssl = .+,ssl = no,' \
        /etc/dovecot/dovecot.conf && \
    sed -Ei \
        -e 's,#log_path =.+,log_path = /dev/stderr,' \
        -e 's,#info_log_path =.+,info_log_path = /dev/stdout,' \
        -e 's,#debug_log_path =.+,debug_log_path = /dev/stdout,' \
        -e 's,^#?auth_verbose = .+,auth_verbose = yes,' \
        /etc/dovecot/conf.d/10-logging.conf && \
    sed -Ei \
        -e 's,#process_min_avail =.+,process_min_avail = 5,' \
        -e 's,#port = 993,port = 0,' \
        /etc/dovecot/conf.d/10-master.conf && \
    sed -Ei \
        -e 's,^#?disable_plaintext_auth = .+,disable_plaintext_auth = no,' \
        -e 's,^#?auth_mechanisms = .+,auth_mechanisms = plain,' \
        /etc/dovecot/conf.d/10-auth.conf && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ADD docker-entrypoint.sh /usr/local/bin/
ADD supervisord.conf /etc/supervisor/
ADD dovecot.conf /etc/supervisor/conf.d/

EXPOSE 143/tcp

ENTRYPOINT ["docker-entrypoint.sh"]

CMD []

WORKDIR /home/vmail/

VOLUME /home/vmail/.mails/
