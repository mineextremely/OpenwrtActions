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
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
#echo 'src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2' >>feeds.conf.default

# 常规目录软件包
git clone https://github.com/sirpdboy/luci-app-advancedplus.git package/luci-app-advancedplus
git clone https://github.com/ophub/luci-app-amlogic package/luci-app-amlogic

'''
# 设置 OpenWrt 根目录
OPENWRT_ROOT=$(pwd)

# =============================
# 添加源码包到 package (完整克隆版本)
# =============================

# 函数：添加指定仓库的特定子目录
add_package() {
    local repo_url="$1"
    local src_path="$2"
    local target_dir="$3"
    
    echo "正在添加: ${target_dir}..."
    
    # 创建目标目录
    local target_path="${OPENWRT_ROOT}/package/${target_dir}"
    mkdir -p "${target_path}"
    
    # 完整克隆仓库
    local temp_dir=$(mktemp -d)
    git clone --depth 1 "${repo_url}" "${temp_dir}"
    
    # 复制所需内容
    cp -R "${temp_dir}/${src_path}/." "${target_path}/"
    
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

# =============================
# 处理 subconverter 文件替换
# =============================

echo "处理 subconverter 文件替换..."

# 定义目标目录
TARGET_DIR="${OPENWRT_ROOT}/package/luci-app-subconverter/root/etc/subconverter"

# 确保目标目录存在
mkdir -p "${TARGET_DIR}"

# 下载二进制文件
echo "下载 subconverter 二进制..."
wget -qO /tmp/subconverter.tar.gz \
    "https://github.com/Aethersailor/subconverter-smart/releases/download/v0.9.12/subconverter_aarch64.tar.gz"

# 创建临时工作目录
TEMP_DIR=$(mktemp -d)
tar -xzf /tmp/subconverter.tar.gz -C "${TEMP_DIR}"

# 清理目标目录（保留 subweb 目录）
if [ -d "${TARGET_DIR}" ]; then
    echo "清理目标目录..."
    cd "${TARGET_DIR}"
    
    # 备份 subweb 目录
    if [ -d "subweb" ]; then
        mv "subweb" "${TEMP_DIR}/subweb_backup"
    fi
    
    # 删除所有内容
    rm -rf "${TARGET_DIR:?}"/*
    
    # 恢复 subweb 目录
    if [ -d "${TEMP_DIR}/subweb_backup" ]; then
        mv "${TEMP_DIR}/subweb_backup" "subweb"
    fi
fi

# 复制解压内容到目标目录
echo "复制新文件到目标目录..."
cp -rf "${TEMP_DIR}/subconverter/." "${TARGET_DIR}/"

# 清理临时文件
rm -rf /tmp/subconverter.tar.gz "${TEMP_DIR}"

echo "subconverter 文件替换完成！"
'''
