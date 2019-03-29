PROJ_FILES := ../../../

include $(PROJ_FILES)Makefile.conf
include $(PROJ_FILES)Makefile.gen

.PHONY: prepare_sphinx

prepare_sphinx:
	$(call cmd,load_libs_docs)
	$(call cmd,load_drvs_docs)
	$(call cmd,load_ewok_docs)
