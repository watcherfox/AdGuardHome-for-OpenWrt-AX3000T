include $(TOPDIR)/rules.mk

PKG_NAME:=adguardhome
PKG_VERSION:=0.107.64
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/AdguardTeam/AdGuardHome.git
PKG_SOURCE_DATE:=2025-08-15  # Замените на дату последнего коммита, если нужно свежее
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:adguard:adguardhome
PKG_MAINTAINER:=Dobroslaw Kijowski <dobo90@gmail.com>, George Sapkin <george@sapk.in>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

FRONTEND_URL:=https://github.com/AdguardTeam/AdGuardHome/releases/download/v$(PKG_VERSION)/
FRONTEND_DEST:=$$ (PKG_NAME)-frontend- $$(PKG_VERSION).tar.gz
FRONTEND_HASH:=8709396e05f812f3e2085a64074384b6363fe1871b9bbb7e8f9886c1aa64b579

PKG_HASH:=0d74004fd17c8f185174fa09deb130ad48e2f46e946eb9fa8c66ce186d2af9cf

PKG_BUILD_DIR:=$$ (BUILD_DIR)/ $$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/adguardhome
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Network-wide ads & trackers blocking DNS server
  URL:=https://github.com/AdguardTeam/AdGuardHome
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +resolveip +iptables +kmod-ipt-nat +@KERNEL_NF_NAT6
endef

define Package/adguardhome/description
  Network-wide software for blocking ads & tracking
  domains at the DNS level.
endef

define Download/adguardhome-frontend
  URL:=$(FRONTEND_URL)
  URL_FILE:=AdGuardHome_frontend.tar.gz
  FILE:=$(FRONTEND_DEST)
  HASH:=$(FRONTEND_HASH)
endef

define Build/Prepare
  $(call Build/Prepare/Default)

  gzip -dc $$ (DL_DIR)/ $$(FRONTEND_DEST) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/ $(TAR_OPTIONS)
endef

define Package/adguardhome/install
  $$ (call GoPackage/Package/Install/Bin, $$(1))
  $(INSTALL_DIR) $(1)/etc/capabilities
  $(INSTALL_CONF) ./files/adguardhome.json $(1)/etc/capabilities/adguardhome.json

  $(INSTALL_DIR) $(1)/etc/config
  $(INSTALL_CONF) ./files/adguardhome.config $(1)/etc/config/adguardhome

  $(INSTALL_DIR) $(1)/etc/init.d
  $(INSTALL_BIN) ./files/adguardhome.init $(1)/etc/init.d/adguardhome

  $(INSTALL_DIR) $(1)/etc/sysctl.d
  $(INSTALL_CONF) ./files/adguardhome.sysctl $(1)/etc/sysctl.d/50-adguardhome.conf

  $(INSTALL_DIR) $(1)/etc/uci-defaults
  $(INSTALL_BIN) ./files/adguardhome.defaults $(1)/etc/uci-defaults/adguardhome
endef

$(eval $(call GoBinPackage,adguardhome))
$(eval $(call BuildPackage,adguardhome))
