nixos_dir=/etc/nixos
dotfiles_dir=~/src/dotfiles

oryp4: populate
	cd ${nixos_dir}
	ln -s ${nixos_dir}/machines/oryp4.nix ${nixos_dir}/configuration.nix

populate: clean
	cp -r ${dotfiles_dir}/machines ${nixos_dir}
	cp -r ${dotfiles_dir}/config ${nixos_dir}
	cp -r ${dotfiles_dir}/overlays ${nixos_dir}
	cp -r ${dotfiles_dir}/security ${nixos_dir}
	cp -r ${dotfiles_dir}/pkgs ${nixos_dir}

clean:
	rm -rf ${nixos_dir}/*

.PHONY: oryp4 populate clean
