# Offload builds to bigboi; its store is served back via Harmonia. Auth is this
# host's SSH host key, authorised as bigboi's `remotebuild` (see remote-builder.nix).
{ ... }:

{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "bigboi";
      sshUser = "remotebuild";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      systems = [ "x86_64-linux" ];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
  ];

  programs.ssh.knownHosts.bigboi.publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWFj0ZjQhnCwLMOMseBuNAejBc0uPzkdJlPZqGv09yZ";
}
