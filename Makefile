PROJ_FILES := ../

include $(PROJ_FILES)m_config.mk
include $(PROJ_FILES)m_generic.mk

# case of make doc without config
ifeq ($(CONFIG_PROJ_NAME),)
PROJNAME = "generic"
else
PROJNAME = $(CONFIG_PROJ_NAME)
endif

TODEL_CLEAN += pdf doxygen latex
TODEL_DISTCLEAN +=

# list of man pages (by now
#
MANS_SYSCALLS_SRC_DIR := $(PROJ_FILES)/kernel/doc/syscalls
MANS_SYSCALLS_SRC := \
	$(MANS_SYSCALLS_SRC_DIR)/sys_init.rst \
	$(MANS_SYSCALLS_SRC_DIR)/sys_log.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_cfg.rst  \
    $(MANS_SYSCALLS_SRC_DIR)/sys_ipc.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_yield.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_get_systick.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_reset.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_sleep.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_lock.rst \
    $(MANS_SYSCALLS_SRC_DIR)/sys_get_random.rst
MANS_SYSCALLS := $(patsubst %.rst,$(BUILD_DIR)/doc/man/man2/%.2,$(notdir $(MANS_SYSCALLS_SRC)))
MANS_SYSCALLS := $(patsubst %.rst,$(BUILD_DIR)/doc/man/man2/%.2,$(notdir $(MANS_SYSCALLS_SRC)))

MANS_STD_SRC_DIR := $(PROJ_FILES)/libs/std/doc/functions
MANS_STD_SRC := \
        $(MANS_STD_SRC_DIR)/aprintf_flush.rst \
        $(MANS_STD_SRC_DIR)/aprintf.rst \
        $(MANS_STD_SRC_DIR)/get_random.rst \
        $(MANS_STD_SRC_DIR)/hexdump.rst \
        $(MANS_STD_SRC_DIR)/memcmp.rst \
        $(MANS_STD_SRC_DIR)/mutex_init.rst \
        $(MANS_STD_SRC_DIR)/mutex_lock.rst \
        $(MANS_STD_SRC_DIR)/mutex_trylock.rst \
        $(MANS_STD_SRC_DIR)/mutex_unlock.rst \
        $(MANS_STD_SRC_DIR)/semaphore_init.rst \
        $(MANS_STD_SRC_DIR)/semaphore_lock.rst \
        $(MANS_STD_SRC_DIR)/semaphore_release.rst \
        $(MANS_STD_SRC_DIR)/semaphore_trylock.rst \
        $(MANS_STD_SRC_DIR)/printf.rst \
        $(MANS_STD_SRC_DIR)/sprintf.rst \
        $(MANS_STD_SRC_DIR)/snprintf.rst \
        $(MANS_STD_SRC_DIR)/vprintf.rst \
        $(MANS_STD_SRC_DIR)/vsprintf.rst \
        $(MANS_STD_SRC_DIR)/vsnprintf.rst \
        $(MANS_STD_SRC_DIR)/strcmp.rst \
        $(MANS_STD_SRC_DIR)/strncmp.rst \
        $(MANS_STD_SRC_DIR)/strlen.rst \
        $(MANS_STD_SRC_DIR)/strcpy.rst \
        $(MANS_STD_SRC_DIR)/strncpy.rst \
        $(MANS_STD_SRC_DIR)/wfree.rst \
        $(MANS_STD_SRC_DIR)/wmalloc_init.rst \
        $(MANS_STD_SRC_DIR)/wmalloc.rst \
        $(MANS_STD_SRC_DIR)/queue_available_space.rst \
        $(MANS_STD_SRC_DIR)/queue_create.rst \
        $(MANS_STD_SRC_DIR)/queue_dequeue.rst \
        $(MANS_STD_SRC_DIR)/queue_enqueue.rst \
        $(MANS_STD_SRC_DIR)/queue_is_empty.rst \
        $(MANS_STD_SRC_DIR)/read_reg_value.rst \
        $(MANS_STD_SRC_DIR)/write_reg_value.rst \
        $(MANS_STD_SRC_DIR)/get_reg_value.rst \
        $(MANS_STD_SRC_DIR)/set_reg_value.rst \
        $(MANS_STD_SRC_DIR)/read_reg16_value.rst \
        $(MANS_STD_SRC_DIR)/write_reg16_value.rst \
        $(MANS_STD_SRC_DIR)/htonl.rst \
        $(MANS_STD_SRC_DIR)/htons.rst

MANS_STD      := $(patsubst %.rst,$(BUILD_DIR)/doc/man/man3/%.3,$(notdir $(MANS_STD_SRC)))

show:
	@echo "MANS_SYSCALLS_SRC: $(MANS_SYSCALLS_SRC)"
	@echo "MANS_SYSCALLS:     $(MANS_SYSCALLS)"
	@echo "MANS_STD_SRC:      $(MANS_STD_SRC)"
	@echo "MANS_STD:          $(MANS_STD)"

.PHONY: $(BUILD_DIR)/doc/kernel_devmap $(BUILD_DIR)/doc/man $(BUILD_DIR)/doc/sphinx preparesphinx

$(BUILD_DIR)/doc/sphinx: preparesphinx
	$(call cmd,mkdir)
	$(call cmd,mklatex)
	$(call cmd,mkhtml)

sphinx: $(BUILD_DIR)/doc/sphinx

preparesphinx:
	$(Q)$(MAKE) -C sphinx/source prepare_sphinx

doc:  $(BUILD_DIR)/doc/sphinx $(BUILD_DIR)/doc/man man

$(BUILD_DIR)/doc/man/man2:
	$(call cmd,mkdir)

$(BUILD_DIR)/doc/man/man3:
	$(call cmd,mkdir)

$(MANS_SYSCALLS): $(MANS_SYSCALLS_SRC_DIR)
	$(call cmd,mkman2)

$(MANS_STD): $(MANS_STD_SRC_DIR)
	$(call cmd,mkman3)

man: $(BUILD_DIR)/doc/man/man2 $(BUILD_DIR)/doc/man/man3 $(MANS_SYSCALLS) $(MANS_STD)

all: doc

__clean:
	BUILDDIR=../$(BUILD_DIR)/doc/sphinx	make -C sphinx clean

__distclean:
	BUILDDIR=../$(BUILD_DIR)/doc/sphinx	make -C sphinx distclean
