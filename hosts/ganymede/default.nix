{...}:
let
  hostName = "ganymede";
in {
  imports = [
    #./impermanence.nix
    ./configuration.nix
  ];
}
