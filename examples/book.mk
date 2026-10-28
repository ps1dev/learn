# Shared by every example: the psyqo build from the nugget submodule, plus
# the CI hook switch.
BOOKDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))..
CPPFLAGS += -I$(BOOKDIR)/ci
ifeq ($(BOOK_CI),true)
CPPFLAGS += -DBOOK_CI -Werror
endif
include $(BOOKDIR)/third_party/nugget/psyqo/psyqo.mk
