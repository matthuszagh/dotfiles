{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matt Huszagh";
    userEmail = "huszaghmatt@gmail.com";

    # TODO how do I set github user?
    extraConfig = {
      github = {
        user = "matthuszagh";
      };
    };

    # TODO configure signing. this is someone elses, just to get an idea.
    # signing = {
    #   signByDefault = true;
    #   key = "9CBF84633C7DDB10";
    # };
  };
}
