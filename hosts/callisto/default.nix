{...}:
let
  hostName = "callisto";
in {
  imports = [
    #./impermanence.nix
    ./configuration.nix
  ];
}
