{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    vendor.config.enable = true;
    vendor.completions.enable = true;
    vendor.functions.enable = true;
  };

  home-manager.users.matt = { ... }: {
    programs.fish = {
      enable = true;
      shellAliases = {
        ll = "${pkgs.coreutils}/bin/ls -Alh";
        rm = "${pkgs.trash-cli}/bin/trash";
      };
      interactiveShellInit = ''
        function vterm_printf;
            if [ -n "$TMUX" ]
                # tell tmux to pass the escape sequences through
                # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
                printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
            else if string match -q -- "screen*" "$TERM"
                # GNU screen (screen, screen-256color, screen-256color-bce)
                printf "\eP\e]%s\007\e\\" "$argv"
            else
                printf "\e]%s\e\\" "$argv"
            end
        end

        function fish_vterm_prompt_end;
            vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
        end
        function track_directories --on-event fish_prompt; fish_vterm_prompt_end; end

        eval (direnv hook fish)
      '';
    };
  };
}
