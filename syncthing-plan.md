Generate key/cert/device id for all devices, store key+cert in sops.

Generating key with `nix-shell -p syncthing --run "syncthing generate --home ~/"`, then key+cert should be in in ~/ then.

From here on, edit sops yaml, add key and cert per host (or should I create new files?)

This should make syncthing available on servers (we probs don't want to run webserver there tho?).
