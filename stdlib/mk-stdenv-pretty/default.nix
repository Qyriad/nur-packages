{
  lib,
  bat,
}: pkg: pkg.overrideAttrs (prev: {
  nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
    bat
  ];

  preHook = assert !(prev ? preHook); ''
    source "${./pre-hook.sh}"
  '';

  postHook = assert !(prev ? postHook); ''
    source "${./post-hook.sh}"
    NIX_DEBUG=4
  '';
})
