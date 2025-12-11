########################################
# 1) web/Dockerfile  (Web Server)
########################################
FROM amazonlinux:2023

# 타임존/기본 툴
RUN yum update -y && \
    yum install -y \
      httpd \
      php php-cli php-fpm php-common php-json php-curl \
      git \
      && yum clean all

RUN rm -rf /var/www/html/* && mkdir -p /var/www/html

ARG GIT_REPO_URL="https://github.com/tegamu/tp.git"
ARG GIT_BRANCH="dev"

RUN git clone -b "$GIT_BRANCH" "$GIT_REPO_URL" /var/www/html && \
    rm -rf /var/www/html/.git

RUN chown -R apache:apache /var/www/html

RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# 기본값 확인
: "${API_BASE:?API_BASE 환경변수를 꼭 지정해야 합니다.}"

# 웹 루트 존재 보장
mkdir -p /var/www/html

# config.php 생성 (EC2 user_data 로직과 동일)
cat > /var/www/html/config.php <<CONFIG_EOF
<?php
\$API_BASE = '${API_BASE}';
?>
CONFIG_EOF

chown apache:apache /var/www/html/config.php

# php-fpm 런타임 디렉토리 보장 (일부 환경에서 필요할 수 있음)
mkdir -p /run/php-fpm

# php-fpm 시작 (daemon 모드로 백그라운드)
php-fpm -D

# Apache를 foreground로 실행 (PID 1)
exec /usr/sbin/httpd -DFOREGROUND
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]

