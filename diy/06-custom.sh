#!/bin/bash -e

# 应用 GCC 补丁
curl -s $mirror/openwrt/patch/generic-24.10/202-toolchain-gcc-add-support-for-GCC-15.patch | patch -p1

# clash_meta
mkdir -p files/etc/openclash/core
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
#GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
#GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
#wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
#wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
chmod +x files/etc/openclash/core/clash*

# clash_config
mkdir -p files/etc/config
wget -qO- https://raw.githubusercontent.com/Kwonelee/Kwonelee/refs/heads/main/rule/openclash > files/etc/config/openclash

# 集成设备无线
#mkdir -p package/base-files/files/lib/firmware/brcm
#cp -a $GITHUB_WORKSPACE/configfiles/firmware/brcm/* package/base-files/files/lib/firmware/brcm/

# 添加设备
echo -e "\\ndefine Device/firefly_station-m2
  \$(Device/rk3566)
  DEVICE_VENDOR := Firefly
  DEVICE_MODEL := Station M2 / RK3566 ROC PC
  DEVICE_DTS := rk3566-roc-pc
  SUPPORTED_DEVICES += firefly,rk3566-roc-pc firefly,station-m2
  UBOOT_DEVICE_NAME := station-m2-rk3566
  DEVICE_PACKAGES := kmod-nvme kmod-scsi-core
endef
TARGET_DEVICES += firefly_station-m2" >> target/linux/rockchip/image/armv8.mk

# 替换package/boot/uboot-rockchip/Makefile
cp -f $GITHUB_WORKSPACE/configfiles/uboot-rockchip/Makefile package/boot/uboot-rockchip/Makefile

# 复制uboot配置、dts到package/boot/uboot-rockchip
mkdir -p package/boot/uboot-rockchip/src/arch/arm/dts
mkdir -p package/boot/uboot-rockchip/src/configs
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3566-roc-pc.dts package/boot/uboot-rockchip/src/arch/arm/dts/
cp -f $GITHUB_WORKSPACE/configfiles/uboot-rockchip/rk3566-station-m2-u-boot.dtsi package/boot/uboot-rockchip/src/arch/arm/dts/
cp -f $GITHUB_WORKSPACE/configfiles/uboot-rockchip/station-m2-rk3566_defconfig package/boot/uboot-rockchip/src/configs/

# 复制dts到files/arch/arm64/boot/dts/rockchip
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3566-roc-pc.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
