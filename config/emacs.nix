{ pkgs, ... }:

let custompkgs = import <custompkgs> {};
in
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
      debbugs
      org-edna
      undo-tree
    ]) ++ (with epkgs.melpaPackages; [
      alert
      auctex-latexmk
      company
      clang-format
      flycheck-clang-analyzer
      helm-exwm
      emms

      cmake-mode
      cmake-font-lock
      elpy
      py-autopep8
      blacken
      yapfify
      sage-shell-mode
      ob-sagemath
      python-info

      # vim-like integration
      evil
      evil-collection
      evil-surround
      evil-magit
      evil-numbers # increment and decrement numbers at point

      cask
      cask-mode
      flycheck-cask
      emr
      elsa
      flycheck
      flycheck-elsa
      wgrep
      dumb-jump
      realgud

      paradox
      general
      git-gutter
      git-timemachine
      github-notifier
      helm
      helm-descbinds
      helm-eww
      helm-org-rifle
      helm-projectile
      helm-recoll
      helm-systemd
      helm-rg
      helm-org
      helpful
      ht
      sx
      elfeed

      notmuch
      helm-notmuch
      ledger-mode
      flycheck-ledger
      evil-ledger

      # shell
      bash-completion
      fish-completion

      # lsp
      lsp-mode
      lsp-ui
      company-lsp
      ccls

      magit
      magithub
      markdown-mode
      multiple-cursors
      nix-mode
      nix-update
      direnv
      no-littering
      nov
      org-board
      # poly-org
      # polymode
      projectile
      rainbow-delimiters
      scad-mode
      slime
      slime-company
      smart-mode-line
      sourcerer-theme
      symon
      transient
      use-package
      which-key
      writegood-mode
      x86-lookup
      yasnippet
    ]) ++ (with epkgs.orgPackages; [
      org
      org-plus-contrib
    ]) ++ (with epkgs; [
      pdf-tools
    ]) ++ (with custompkgs; [
      org-recoll
      layers
      justify-kp
    ]));
  };
}
