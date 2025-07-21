{
  strace,
  fetchpatch,
}:

# Strace patched to have colored output.
strace.overrideAttrs (prev: {
  patches = let
    colorPatch = fetchpatch {
      url = "https://raw.githubusercontent.com/xfgusta/strace-with-colors/v6.3-1/strace-with-colors.patch";
      hash = "sha256-gcQldGsRgvGnrDX0zqcLTpEpchNEbCUFdKyii0wetEI=";
    };
  in prev.patches or [ ] ++ [ colorPatch ];

  passthru.allowUnstructuredAttrs = true;

  meta = prev.meta // {
    description = prev.meta.description + " (with xfgusta's colors patch)";
  };
})
