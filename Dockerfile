FROM amazonlinux:2023

# Apache + PHP + git 설치
RUN yum update -y && \
    yum install -y \
      httpd \
      php php-cli php-fpm php-common php-json php-curl \
      git \
    && yum clean all

# 웹 루트 초기화
RUN rm -rf /var/www/html/* && mkdir -p /var/www/html

# Git 리포지토리에서 코드 가져오기
ARG GIT_REPO_URL="https://github.com/tegamu/tp.git"
ARG GIT_BRANCH="dev"

RUN git clone -b "$GIT_BRANCH" "$GIT_REPO_URL" /var/www/html && \
    rm -rf /var/www/html/.git && \
    chown -R apache:apache /var/www/html

# entrypoint 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

