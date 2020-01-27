{ config, pkgs, ... }:

{
  programs.bash = {
    shellAliases = {
      ls = "${pkgs.coreutils}/bin/ls --color=auto";
      ll = "${pkgs.coreutils}/bin/ls -Alh";
      rm = "${pkgs.trash-cli}/bin/trash";
    };
    shellInit = ''
    export KICAD_SYMBOL_DIR=${pkgs.kicad.out}/share/kicad/library
    '';
    enableCompletion = true;
    # promptInit = ''
    #   # Provide a nice prompt if the terminal supports it.
    #   if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
    #     PROMPT_COLOR="01;34m"
    #     PS1="\[\033[$PROMPT_COLOR\]\w\[\033[$PROMPT_COLOR\] \$ \[\033[00m\]"
    #   fi
    # '';
  };

}
