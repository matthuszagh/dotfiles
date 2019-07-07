{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matt Huszagh";
    userEmail = "huszaghmatt@gmail.com";

    # TODO configure signing. this is someone elses, just to get an idea.
    # signing = {
    #   signByDefault = true;
    #   key = "9CBF84633C7DDB10";
    # };
  };
}
