{
  lib,
  strace,
  fetchpatch,
}:

# Strace patched to have colored output.
strace.overrideAttrs (prev: {
  patches = prev.patches or [ ] ++ lib.singleton (fetchpatch {
    url = "https://raw.githubusercontent.com/xfgusta/strace-with-colors/v6.3-1/strace-with-colors.patch";
    hash = "sha256-gcQldGsRgvGnrDX0zqcLTpEpchNEbCUFdKyii0wetEI=";
  });

  meta = prev.meta // {
    description = prev.meta.description + " (with xfgusta's colors patch)";
  };
})
