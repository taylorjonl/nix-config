<h2 align="center">taylorjonl's Nix Config</h2>

This repository is home to the nix code that builds my systems.

```
├── hosts
│   ├── <name>
│   │   ├── configuration.nix
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── common.nix
├── modules
│   ├── hardware
│   │   ├── mac-mini-6.2.nix
│   │   └── nvidia-rtx.nix
│   ├── roles
│   │   └── desktop.nix
│   └── services
│       └── xserver.nix
├── flake.lock
└── flake.nix
```
