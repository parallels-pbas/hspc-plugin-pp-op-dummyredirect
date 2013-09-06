PREFIX			= /
HSPC_TEMPLATE   = $(PREFIX)/var/opt/hspc-root/template
PLUGIN_PATH     = $(HSPC_TEMPLATE)/HSPC/Plugin/PP/OP_DummyRedirect/
PLUGIN_MT_PATH  = $(HSPC_TEMPLATE)/HSPC/MT/Plugin/PP/OP_DummyRedirect/

PLUGIN_TMPLS    = op_dummyredirect_edit.tmpl op_dummyredirect_view.tmpl
MT_PLUGIN_TMPLS = gate_page.tmpl


MKDIR           = mkdir -p

all:

install:
	$(MKDIR) $(PAYMETHOD_PATH) $(PLUGIN_PATH)
	
	@for i in $(PLUGIN_TMPLS); do \
	  install -m 644 $$i $(PLUGIN_PATH); \
	done

	@for i in $(MT_PLUGIN_TMPLS); do \
	  install -D -m 644 $$i $(PLUGIN_MT_PATH)/$$i; \
	done

	for i in `find . -type f -name *.html | grep -v svn`; do \
		install -Dm644 $$i $(PLUGIN_PATH)/$$i || exit $?; \
	done

clean:
