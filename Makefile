PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SYSCONFDIR ?= /etc/microback

.PHONY: all install uninstall

all:
	@echo "Nothing to compile. Run 'sudo make install' to install microback."

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 microback $(DESTDIR)$(BINDIR)/microback
	install -d $(DESTDIR)$(SYSCONFDIR)/configs
	install -d $(DESTDIR)$(SYSCONFDIR)/enabled.d
	install -d $(DESTDIR)/var/log/microback
	install -d $(DESTDIR)/var/lib/microback
	@echo "microback installed successfully to $(DESTDIR)$(BINDIR)/microback"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/microback
	@echo "microback binary removed. Configs in $(SYSCONFDIR) were preserved."
