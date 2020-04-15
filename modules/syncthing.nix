{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    declarative = {
      folders = {
        "src" = {
          path = "/home/matt/src";
          devices = [ "ryzen3950" "oryp4" ];
        };
        "doc" = {
          path = "/home/matt/doc";
          devices = [ "ryzen3950" "oryp4" ];
        };
      };

      devices = {
        ryzen3950 = {
          # addresses = [  ];
          id = "ARE2A7I-MZ5DSK7-KDAH5WB-L4455LJ-JSJUNTW-XBOQKBF-KKJ3I5E-OP2LHAC";
        };
        oryp4 = {
          id = "YQIDZ2A-IQO2SYY-ESQWJ5I-WOLAWEM-VCL6ET3-7TTEUQD-CZYF3KO-VGSFRAO";
        };
      };
    };
  };
}
