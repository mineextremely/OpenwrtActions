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

#
# add_package "https://github.com/user/repo2" \
#    "subdir/package" \
#    "another-package"
