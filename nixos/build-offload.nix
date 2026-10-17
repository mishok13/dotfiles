# Offload builds to bigboi so built paths land in its store, which Harmonia then
# serves back to everyone. Auth uses this host's SSH host key as root's identity
# (bigboi's `remotebuild` user authorises it, see nixos/remote-builder.nix).
{ ... }:

{
  nix.distributedBuilds = true;
  # Let bigboi fetch dependencies from substituters itself instead of copying
  # them over from this host.
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
