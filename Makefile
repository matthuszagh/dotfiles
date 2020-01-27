NIXOS_DIR	= /etc/nixos
SRC_DIR		= /home/matt/src
DOTFILES_DIR	= $(SRC_DIR)/dotfiles
HOSTNAME 	= $(shell hostname)

.PHONY: rebuild
rebuild: populate
	sudo nixos-rebuild switch --keep-going

.PHONY: rebuild_trace
rebuild_trace: populate
	sudo nixos-rebuild switch --show-trace

.PHONY: bootstrap
bootstrap: populate
	sudo nixos-rebuild switch -I nix=$(SRC_DIR)/nix -I nixpkgs=$(SRC_DIR)/nixpkgs -I custompkgs=$(SRC_DIR)/dotfiles/custompkgs --keep-going

.PHONY: populate
populate: clean clean_flycheck_elc
	cp $(DOTFILES_DIR)/configuration.nix $(NIXOS_DIR)
	cp $(DOTFILES_DIR)/hardware/$(HOSTNAME)-hardware-configuration.nix $(NIXOS_DIR)/hardware-configuration.nix
	cp -r $(DOTFILES_DIR)/config $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/services $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/modules $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/overlays $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/security $(NIXOS_DIR)

.PHONY: clean_flycheck_elc
clean_flycheck_elc:
	find $(DOTFILES_DIR)/config/emacs/layers/ -name 'flycheck_[A-Za-z0-9]*\.elc' -delete

.PHONY: clean
clean:
	rm -rf $(NIXOS_DIR)/*
