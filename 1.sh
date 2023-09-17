#!/bin/bash

# 设置变量
MYSQL_VERSION="8.0.34"
ARCH="amd64"
PKG_NAME="mysql-${MYSQL_VERSION}-${ARCH}"

# 创建工作目录
WORK_DIR="/tmp/${PKG_NAME}"
mkdir -p "$WORK_DIR/DEBIAN"
mkdir -p "$WORK_DIR/usr/bin"

# 复制 MySQL 二进制文件到目标目录
cp mysql "$WORK_DIR/usr/bin/mysql"

# 创建控制文件 (control file)
cat <<EOF > "$WORK_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $MYSQL_VERSION
Section: database
Priority: optional
Architecture: $ARCH
Maintainer: Your Name <your.email@example.com>
Description: MySQL Database Server
EOF

# 设置权限和所有者
chmod 755 "$WORK_DIR/DEBIAN/control"

# 使用 dpkg-deb 创建软件包
dpkg-deb --build "$WORK_DIR" "$PKG_NAME.deb"

# 移动软件包到当前目录
mv "$PKG_NAME.deb" .

# 清理临时目录
rm -rf "$WORK_DIR"

echo "MySQL Debian 软件包已创建：$PKG_NAME.deb"