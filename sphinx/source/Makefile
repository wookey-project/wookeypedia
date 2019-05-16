PROJ_FILES := ../../../

include $(PROJ_FILES)m_config.mk
include $(PROJ_FILES)m_generic.mk

.PHONY: prepare_sphinx

prepare_sphinx:
	$(call cmd,load_libs_docs)
	$(call cmd,load_drvs_docs)
	$(call cmd,load_kern_docs)
	$(call cmd,load_jvc_docs)
