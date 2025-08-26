# Nixpkgs' `config` argument.
# Used by:
# flake.nix
# default.nix

{
  warnUndeclaredOptions = false;
  allowAliases = false;
  checkMeta = true;
  permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];
}
