#################################################
# OpenWrt Makefile for Node.js 5 (includes NPM) #
#################################################
include $(TOPDIR)/rules.mk

# Name and release number of this package
PKG_NAME:=nodejs5
PKG_VERSION:=5.6.0
PKG_RELEASE:=1

NODE_MAJOR_VER:=$(shell echo $(PKG_VERSION) | cut -f1 -d.)

PKG_SOURCE:=node-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://nodejs.org/dist/v$(PKG_VERSION)/
PKG_MD5SUM:=6f7c2cec289a20bcd970240dd63c1395
PKG_MAINTAINER:="Andy Savage <andy@savage.hk>"

PKG_INSTALL:=0

PKG_BUILD_DIR:=$(BUILD_DIR)/node-v$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

include $(INCLUDE_DIR)/package.mk

# Set some package defaults
define Package/$(PKG_NAME)/Default
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=nodejs$(NODE_MAJOR_VER).
	MENU:=1
endef

define Package/npmjs
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=npmjs$(NODE_MAJOR_VER).
	DEPENDS:=+nodejs$(NODE_MAJOR_VER)
	MENU:=1
endef

# Node.js Package
define Package/$(PKG_NAME)
	$(call Package/$(PKG_NAME)/Default)
	DEPENDS:=+libpthread +librt +libstdcpp
	ifeq ($(CONFIG_NODEJS_WITH_SSL),y) && ($(CONFIG_NODEJS_SHARED_OPENSSL),y)
	 	DEPENDS += +libopenssl
	endif
	ifeq ($(CONFIG_NODEJS_SHARED_ZLIB),y)
	 	DEPENDS += +zlib
	endif
	ifeq ($(CONFIG_NODEJS_SHARED_LIBUV),y)
	 	DEPENDS += +libuv
	endif
	ifeq ($(CONFIG_NODEJS_SHARED_HTTP_PARSER),y)
	 	DEPENDS += +libhttp-parser
	endif
endef

define Package/$(PKG_NAME)/description
	Node.js® is a JavaScript runtime built on Chrome's V8 JavaScript engine. Node.js uses
	an event-driven, non-blocking I/O model that makes it lightweight and efficient.
endef

define Package/npmjs/description
	NPM (for Node.js), is the largest ecosystem of open source libraries in the world.
endef

CPU:=$(subst x86_64,x64,$(subst i386,ia32,$(ARCH)))

# Set some defaults
CONFIG_NODEJS_SHARED_ZLIB:=y
CONFIG_NODEJS_SHARED_HTTP_PARSER:=y
CONFIG_NODEJS_SHARED_LIBUV:=n
CONFIG_NODEJS_SHARED_OPENSSL:=y
CONFIG_NODEJS_WITH_SSL:=y
CONFIG_NODEJS_BUILD_WITH_NPM:=y

define Package/$(PKG_NAME)/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS= \
	--dest-cpu=$(CPU) \
	--dest-os=linux \
	--prefix=/usr \
	--without-snapshot

ifeq ($(CONFIG_NODEJS_SHARED_ZLIB),y)
	CONFIGURE_ARGS += \
		 --shared-zlib \
		 --shared-zlib-libpath="$(STAGING_DIR)/usr/lib" \
		 --shared-zlib-includes="$(STAGING_DIR)/usr/include"
endif
ifeq ($(CONFIG_NODEJS_SHARED_LIBUV),y)
	CONFIGURE_ARGS += \
		 --shared-libuv \
		 --shared-libuv-libpath="$(STAGING_DIR)/usr/lib" \
		 --shared-libuv-includes="$(STAGING_DIR)/usr/include"
endif
ifeq ($(CONFIG_NODEJS_SHARED_HTTP_PARSER),y)
	CONFIGURE_ARGS += \
		 --shared-http-parser \
		 --shared-http-parser-libpath="$(STAGING_DIR)/usr/lib" \
		 --shared-http-parser-includes="$(STAGING_DIR)/usr/include"
endif
ifeq ($(CONFIG_NODEJS_WITH_SSL),y)
	 ifeq ($(CONFIG_NODEJS_SHARED_OPENSSL),y)
	 	CONFIGURE_ARGS += \
			 --shared-openssl \
			 --shared-openssl-libpath="$(STAGING_DIR)/usr/lib" \
			 --shared-openssl-includes="$(STAGING_DIR)/usr/include"
	 endif
else
	CONFIGURE_ARGS += --without-ssl
endif
ifeq ($(CONFIG_NODEJS_BUILD_WITH_NPM),n)
	CONFIGURE_ARGS += --without-npm
endif
ifeq ($(CONFIG_NODEJS_DEBUG_BUILD_ENABLED),n)
	CONFIGURE_ARGS += --debug
endif
# This one is untested, does it need an additional dependency?
ifeq ($(CONFIG_NODEJS_GDB_SUPPORT_ENABLED),n)
	CONFIGURE_ARGS += --gdb
endif

# Set any additional User defined v8 engine options
ifneq ($(CONFIG_NODEJS_V8_OPTIONS),)
	#--max_old_space_size=20 --initial_old_space_size=4 --max_semi_space_size=2 --max_executable_size=5
	CONFIGURE_ARGS += --v8-options="$(CONFIG_NODEJS_V8_OPTIONS)"
endif

# Configure Additional CPU Type Options
ifneq ($(CONFIG_NODEJS_CPU_TYPE_DEFAULT),y)
	ifeq ($(CONFIG_NODEJS_CPU_TYPE_MIPS),y)
		ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_LOONSON),y)
			CONFIGURE_ARGS += --with-mips-arch-variant=loongson
		else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R1),y)
			CONFIGURE_ARGS += --with-mips-arch-variant=r1
		else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R2),y)
			CONFIGURE_ARGS += --with-mips-arch-variant=r2
		else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_R6),y)
			CONFIGURE_ARGS += --with-mips-arch-variant=r6
		else ifeq ($(CONFIG_NODEJS_MIPS_ARCH_VARIANT_RX),y)
			CONFIGURE_ARGS += --with-mips-arch-variant=rx
		endif
		ifeq ($(CONFIG_NODEJS_ABI_MIPS_TYPE_SOFT),y)
			CONFIGURE_ARGS += --with-mips-float-abi=soft
		else ifeq ($(CONFIG_NODEJS_ABI_MIPS_TYPE_HARD),y)
			CONFIGURE_ARGS += --with-mips-float-abi=hard
		endif
		ifeq ($(CONFIG_NODEJS_FPU_MIPS_FP32),y)
			CONFIGURE_ARGS += --with-mips-fpu-mode=fp32
		else ifeq ($(CONFIG_NODEJS_FPU_MIPS_FP64),y)
			CONFIGURE_ARGS += --with-mips-fpu-mode=fp64
		else ifeq ($(CONFIG_NODEJS_FPU_MIPS_FPXX),y)
			CONFIGURE_ARGS += --with-mips-fpu-mode=fpxx
		endif
	else ifeq ($(CONFIG_NODEJS_CPU_TYPE_ARM),y)
		ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFP),y)
			CONFIGURE_ARGS += --with-arm-fpu=vfp
		else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFPV3),y)
			CONFIGURE_ARGS += --with-arm-fpu=vfpv3
		else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_VFPV3_D16),y)
			CONFIGURE_ARGS += --with-arm-fpu=vfpv3-d16
		else ifeq ($(CONFIG_NODEJS_FPU_ARM_USE_NEON),y)
			CONFIGURE_ARGS += --with-arm-fpu=neon
		endif
		ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_SOFT),y)
			CONFIGURE_ARGS += --with-arm-float-abi=soft
		else ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_SOFTFP),y)
			CONFIGURE_ARGS += --with-arm-float-abi=softfp
		else ifeq ($(CONFIG_NODEJS_ABI_ARM_TYPE_HARD),y)
			CONFIGURE_ARGS += --with-arm-float-abi=hard
		endif
	endif
endif

define Package/$(PKG_NAME)/install
	mkdir -p $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/node $(1)/usr/bin/node$(NODE_MAJOR_VER)
	ifeq ($(CONFIG_NODEJS_CREATE_SYMLINKS),y)
		ln -s $(1)/usr/bin/node$(NODE_MAJOR_VER) $(1)/usr/bin/node
	endif
endef

define Package/npmjs/install
	mkdir -p $(1)/usr/bin
	mkdir -p $(1)/usr/lib/node_modules/npm/{bin,lib,node_modules}
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/npm $(1)/usr/bin/npm
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/{package.json,LICENSE,cli.js} $(1)/usr/lib/node_modules/npm
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/bin/npm-cli.js $(1)/usr/lib/node_modules/npm/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/lib/* $(1)/usr/lib/node_modules/npm/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/node_modules/npm/node_modules/* $(1)/usr/lib/node_modules/npm/node_modules/
endef

# build a package.
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,npmjs))
