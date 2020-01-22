NIXOS_DIR	= /etc/nixos
DOTFILES_DIR	= ~/src/dotfiles
MACHINE		= ryzen3950

.PHONY: rebuild
rebuild: $(MACHINE)
	sudo nixos-rebuild switch --keep-going

.PHONY: rebuild_trace
rebuild_trace: $(MACHINE)
	sudo nixos-rebuild switch --show-trace

.PHONY: bootstrap
bootstrap: $(MACHINE)
	sudo nixos-rebuild switch -I nix=/home/matt/src/nix -I nixpkgs=/home/matt/src/nixpkgs -I custompkgs=/home/matt/src/custompkgs --keep-going

.PHONY: ryzen3950
ryzen3950: populate
	cd $(NIXOS_DIR)
	ln -s $(NIXOS_DIR)/machines/ryzen3950/configuration.nix $(NIXOS_DIR)/configuration.nix

.PHONY: mbp
mbp: populate
	cd $(NIXOS_DIR)
	ln -s $(NIXOS_DIR)/machines/mbp/configuration.nix $(NIXOS_DIR)/configuration.nix

.PHONY: oryp4
oryp4: populate
	cd $(NIXOS_DIR)
	ln -s $(NIXOS_DIR)/machines/oryp4/configuration.nix $(NIXOS_DIR)/configuration.nix

.PHONY: populate
populate: clean clean_flycheck_elc
	cp -r $(DOTFILES_DIR)/machines $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/config $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/overlays $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/security $(NIXOS_DIR)
	cp -r $(DOTFILES_DIR)/pkgs $(NIXOS_DIR)

.PHONY: clean_flycheck_elc
clean_flycheck_elc:
	find $(DOTFILES_DIR)/config/emacs/layers/ -name 'flycheck_[A-Za-z0-9]*\.elc' -delete

.PHONY: clean
clean:
	rm -rf $(NIXOS_DIR)/*
