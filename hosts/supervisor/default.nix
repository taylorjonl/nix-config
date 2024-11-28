{...}:
let
  hostName = "supervisor";
in {
  imports = [
    #./impermanence.nix
    ./configuration.nix
  ];
}
