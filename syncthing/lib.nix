{
  lib,
  hostname,
  homeDir,
}:

let
  folderSpec = import ./folders.nix;

  hostFolders = lib.filterAttrs (
    _: spec: builtins.any (dev: dev.name == hostname) spec.members
  ) folderSpec;

  remoteDevices = lib.listToAttrs (
    map (dev: lib.nameValuePair dev.name (removeAttrs dev [ "name" ])) (
      builtins.filter (dev: dev.name != hostname) (
        lib.concatMap (spec: spec.members) (builtins.attrValues hostFolders)
      )
    )
  );
in
{
  enabled = hostFolders != { };
  devices = remoteDevices;
  folders = lib.mapAttrs (_: spec: {
    path = "${homeDir}/${spec.path}";
    inherit (spec) ignoreDelete;
    devices = map (dev: dev.name) (builtins.filter (dev: dev.name != hostname) spec.members);
  }) hostFolders;
}
