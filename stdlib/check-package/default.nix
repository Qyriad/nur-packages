{
  lib,
}: {
  structuredAttrs = name: drv: (
    lib.warnIf (drv.__structuredAttrs or false || drv.allowUnstructuredAttrs or false)
      "missing __structuredAttrs for package '${name}' (${drv.name})"
    drv
  );

  strictDeps = name: drv: (
    lib.warnIf (drv.strictDeps or false || drv.allowUnstrictDeps or false)
      "missing strictDeps for package '${name}' (${drv.name})"
  );
}
