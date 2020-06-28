NIXOS_DIR		= /etc/nixos
SRC_DIR			= /home/matt/src
DOTFILES_DIR		= $(SRC_DIR)/dotfiles
NIXOS_DOTFILES_DIR	= $(DOTFILES_DIR)/nixos
EMACS_DOTFILES_DIR	= $(DOTFILES_DIR)/emacs
HOSTNAME 		= $(shell hostname)

.PHONY: rebuild
rebuild: populate
	sudo nixos-rebuild switch --keep-going

.PHONY: rebuild_trace
rebuild_trace: populate
	sudo nixos-rebuild switch --show-trace

.PHONY: rebuild_boot
rebuild_boot: populate
	sudo nixos-rebuild boot --keep-going

.PHONY: bootstrap
bootstrap: populate
	sudo nixos-rebuild switch \
		-I custompkgs=$(NIXOS_DOTFILES_DIR)/custompkgs \
		-I nix=$(SRC_DIR)/nix \
		-I nur=$(SRC_DIR)/NUR \
		-I nixpkgs=$(SRC_DIR)/nixpkgs \
		-I nixpkgs-overlays=$(NIXOS_DOTFILES_DIR)/overlays \
		-I nixos-config=$(NIXOS_DOTFILES_DIR)/configuration.nix \
		-I /nix/var/nix/profiles/per-user/root/channels \
		--show-trace

.PHONY: populate
populate: clean clean_flycheck_elc
	ln -sf $(NIXOS_DOTFILES_DIR)/hardware/$(HOSTNAME)-hardware-configuration.nix \
		$(NIXOS_DOTFILES_DIR)/hardware-configuration.nix

.PHONY: clean_flycheck_elc
clean_flycheck_elc:
	find $(EMACS_DOTFILES_DIR)/layers/ \
		-name 'flycheck_[A-Za-z0-9]*\.elc' -delete

.PHONY: clean
clean:
	rm -rf $(NIXOS_DIR)/*
