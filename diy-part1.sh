#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo 'src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2' >>feeds.conf.default

# 常规目录软件包
git clone https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus

# =============================
# 硬编码添加多个源码包到 package
# =============================

# 函数：添加指定仓库的特定子目录
add_package() {
    local repo_url="$1"
    local src_path="$2"
    local target_dir="$3"
    
    echo "正在添加: ${target_dir}..."
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    
    # 稀疏克隆仓库
    git clone --depth 1 --filter=blob:none --sparse "${repo_url}" "${temp_dir}"
    (
        cd "${temp_dir}"
        git sparse-checkout init --cone
        git sparse-checkout set "${src_path}"
        
        # 移动到目标位置
        mkdir -p "../../package/${target_dir}"
        mv "${src_path}"/* "../../package/${target_dir}/"
    )
    
    # 清理临时目录
    rm -rf "${temp_dir}"
}

# 添加 luci-app-amlogic
add_package "https://github.com/ophub/luci-app-amlogic" \
    "main/luci-app-amlogic" \
    "luci-app-amlogic"

# 添加 luci-app-subconverter
add_package "https://github.com/0x2196f3/luci-app-subconverter" \
    "main/luci-app-subconverter" \
    "luci-app-subconverter"

# 添加 luci-theme-kucat
add_package "https://github.com/sirpdboy/luci-theme-kucat" \
    "js/luci-theme-kucat" \
    "luci-theme-kucat"

# =============================
# 处理 subconverter 文件替换
# =============================

echo "处理 subconverter 文件替换..."

# 定义目标目录
TARGET_DIR="package/luci-app-subconverter/root/etc/subconverter"

# 下载二进制文件
echo "下载 subconverter 二进制..."
wget -qO /tmp/subconverter.tar.gz \
    "https://github.com/Aethersailor/subconverter-smart/releases/download/v0.9.12/subconverter_aarch64.tar.gz"

# 创建临时工作目录
TEMP_DIR=$(mktemp -d)
tar -xzf /tmp/subconverter.tar.gz -C $TEMP_DIR

# 清理目标目录（保留 subweb 目录）
if [ -d "$TARGET_DIR" ]; then
    echo "清理目标目录..."
    cd "$TARGET_DIR"
    # 创建 subweb 临时备份
    mkdir -p $TEMP_DIR/subweb_backup
    [ -d "subweb" ] && mv subweb $TEMP_DIR/subweb_backup/
    
    # 删除除 subweb 外的所有内容
    find . -mindepth 1 -maxdepth 1 ! -name 'subweb' -exec rm -rf {} +
    
    # 恢复 subweb 目录
    [ -d "$TEMP_DIR/subweb_backup/subweb" ] && mv $TEMP_DIR/subweb_backup/subweb .
fi

# 复制解压内容到目标目录
echo "复制新文件到目标目录..."
cp -rf $TEMP_DIR/subconverter/* "$TARGET_DIR/"

# 清理临时文件
rm -rf /tmp/subconverter.tar.gz $TEMP_DIR

echo "subconverter 文件替换完成！"
