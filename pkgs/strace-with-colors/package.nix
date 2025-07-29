{
  strace,
  fetchpatch2,
}:

# Strace patched to have colored output.
strace.overrideAttrs (final: prev: {
  # Based on the patch from https://github.com/xfgusta/strace-with-colors
  colorPatch = fetchpatch2 {
    url = "https://raw.githubusercontent.com/Qyriad/strace-with-colors/v6.3-2/strace-with-colors.patch";
    hash = "sha256-PxzYx6BbiZfXgqlpQUWNugEvBulIXBHmo9eJp0+ylMI=";
  };
  patches = prev.patches or [ ] ++ [ final.colorPatch ];

  passthru.allowUnstructuredAttrs = true;

  meta = prev.meta // {
    description = prev.meta.description + " (with xfgusta's colors patch)";
  };
})
