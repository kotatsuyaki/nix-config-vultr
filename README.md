# NixOS Configuration for my Vultr Instance

## Remote rebuild command

```
NIX_SSHOPTS=-t nixos-rebuild switch \
    --flake .#gitserver \
    --target-host taki@vultr \
    --build-host localhost \
    --impure --use-remote-sudo
```
