#
# Configuration
#

# CC
CC=gcc                           #用gcc编译程序
# Path to parent kernel include files directory   
LIBC_INCLUDE=/usr/include        #设置库函数路径
# Libraries 
ADDLIB= 
# Linker flags
LDFLAG_STATIC=-Wl,-Bstatic        #连接静态库,-Bstatic参数保证链接器对接下来的-l选项使用静态链接
LDFLAG_DYNAMIC=-Wl,-Bdynamic      #连接动态库
LDFLAG_CAP=-lcap                  #连接CAP分布式数据库
LDFLAG_GNUTLS=-lgnutls-openssl    #连接GNUTLS安全通讯库
LDFLAG_CRYPTO=-lcrypto            #连接密码类库
LDFLAG_IDN=-lidn                  #连接IDN域名库
LDFLAG_RESOLV=-lresolv            #连接RESOLV库
LDFLAG_SYSFS=-lsysfs              #连接SYSFS接口函数库

#
# Options
#

# Capability support (with libcap) [yes|static|no]    #能力支持，设置开关
USE_CAP=yes          #支持CAP函数库
# sysfs support (with libsysfs - deprecated) [no|yes|static]   #[否，静态，是]
USE_SYSFS=no         #支持SYSFS库
# IDN support (experimental) [no|yes|static]
USE_IDN=no           #支持IDN库

# Do not use getifaddrs [no|yes|static]      #不要使用getifaddrs [否/是/静态]
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []       #apr默认设备 
#使用arping向目的主机发送ARP报文，通过目的主机的IP获得该主机的硬件地址
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]  #TSL库ping6的状态
#使用 ping可以测试计算机名和计算机的ip地址，验证与远程计算机的连接
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]   #CRYPTO库ping6的状态，共享
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]     #RESOLV库ping6的状态
USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]   #ping6资源路径
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]    #RDISC服务器支持（默认-r选项）
#rdisc是路由器发现守护程序
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.  #所有新的gcc都是有问题的，并且-Werror命令不工作。
#-Werror 把所有的告警都转化为编译错误。只要有告警就停止编译。
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
#-fno-strict-aliasing，编译器认为任何 指针都可能指向同一个内存区域;
#-fstrict-aliasing的时候编译器会假设不同类型的指针指向的内存不会重叠来进行优化
#-Wstrict-prototypes         使用了非原型的函数声明时给出警告
#-Wall参数,编辑器将列出所有的警告信息
#-g 生成调试信息
CCOPTOPT=-O3   #-O优化参数，-O3一般为最高级别
GLIBCFIX=-D_GNU_SOURCE  #_GNU_SOURCE宏,表示编写符合 GNU 规范的代码
DEFINES=
LDLIB=

FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
#判断CRYPTO库中函数是否重复
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
# 判断CAP库中函数是否重复
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
#判断SYSFS库中函数是否重复
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
#判断IDN库中函数是否重复
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
#缺省FADDRS
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
#保障RDISC服务器
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
#保障ping6文件
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd  #ipv4对象：iputils包含的七个工具
IPV6_TARGETS=tracepath6 traceroute6 ping6                       #ipv6对象：tracepath6 traceroute6 ping6 
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)                         #可执行文件列表

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

all: $(TARGETS)                       
#要编译的可执行文件列表

%.s: %.c                              
#用通配符编译文件
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@       #patsubst用于有函数依赖于外部库的情况
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除, DEF_ping
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)
# $(patsubst %.o,%,$@) 的意思是把指定filename.o文件变为filename
# patsubst函数：3个参数。功能是将第三个参数中的每一项（由空格分隔）符合第一个参数描述的部分替换成第二个参数制定的值
# -------------------------------------
# arping    # 使用arping向目的主机发送ARP报文，通过目的主机的IP获得该主机的硬件地址
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif

# clockdiff    #使用clockdiff可以测算目的主机和本地主机的系统时间差。clockdiff程序由clockdiff.c文件构成。
LIB_clockdiff = $(LIB_CAP)

# ping / ping6    
#使用 ping可以测试计算机名和计算机的ip地址，验证与远程计算机的连接。ping程序由ping.c ping6.cping_common.c ping.h 文件构成
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd    #rarpd是逆地址解析协议的服务端程序。rarpd程序由rarpd.c文件构成。
DEF_rarpd =
LIB_rarpd =

# rdisc     #rdisc是路由器发现守护程序。rdisc程序由rdisc.c文件构成。
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath     #与traceroute功能相似，使用tracepath测试IP数据报文从源主机传到目的主机经过的路由。tracepath程序由tracepath.c tracepath6.c traceroute6.c 文件构成。
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd   #tftpd是简单文件传送协议TFTP的服务端程序。tftpd程序由tftp.h tftpd.c tftpsubs.c文件构成。
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
ninfod:
	@set -e; \       # 如果命令带非零值返回,退出
		if [ ! -f ninfod/Makefile ]; then \     # 当file存在并且是正规文件时返回真
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules

# -------------------------------------
man:
	$(MAKE) -C doc man

html:
	$(MAKE) -C doc html

clean:
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2

