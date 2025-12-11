#!/bin/bash
set -e

# API_BASE 환경변수 필수 체크
: "${API_BASE:?API_BASE 환경변수를 꼭 지정해야 합니다.}"

# 웹 루트 존재 보장
mkdir -p /var/www/html

# config.php 생성
cat > /var/www/html/config.php <<CONFIG_EOF
<?php
\$API_BASE = '${API_BASE}';
?>
CONFIG_EOF

# 권한 설정
chown apache:apache /var/www/html/config.php

# php-fpm 런타임 디렉토리 보장
mkdir -p /run/php-fpm

# php-fpm을 백그라운드로 실행
php-fpm -D

# Apache를 foreground로 실행 (PID 1)
exec /usr/sbin/httpd -DFOREGROUND

