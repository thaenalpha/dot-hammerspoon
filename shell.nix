{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/1c6eb4876f71e8903ae9f73e6adf45fdbebc0292.tar.gz") {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [ lua luaPackages.luacheck ];
}
