{ pkgs, ... }:

{
  home.file.".emacs.d/init.el".source = /home/matt/src/dotfiles/config/emacs/init.el;
  home.file.".emacs.d/layers".source = /home/matt/src/dotfiles/config/emacs/layers;
  home.file.".emacs.d/layers".recursive = true;

  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: (with epkgs.elpaPackages; [
      aggressive-indent
      auctex
      exwm
      org-edna
      undo-tree
    ]) ++ (with epkgs.melpaPackages; [
      company
      helm-exwm
      evil
      evil-collection
      evil-surround
      evil-magit
      general
      git-gutter
      helm
      helm-descbinds
      helm-eww
      helm-org-rifle
      helm-projectile
      helm-rg
      helpful
      ht
      load-bash-alias
      magit
      markdown-mode
      multiple-cursors
      nix-mode
      nix-update
      no-littering
      nov
      poly-org
      polymode
      projectile
      rainbow-delimiters
      smart-mode-line
      sourcerer-theme
      transient
      use-package
      which-key
      writegood-mode
      x86-lookup
    ]) ++ (with epkgs.orgPackages; [
      org
      org-plus-contrib
    ]) ++ (with epkgs; [
      pdf-tools
    ]));
  };
}
