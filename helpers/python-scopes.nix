{
  pkgs,
  lib,
  pythonInterpreters,
}: let
  inherit (builtins) tryEval;
in pythonInterpreters
|> lib.filterAttrs (name: _: lib.hasAttr "${name}Packages" pkgs)
|> lib.filterAttrs (_: py: lib.tryResOr (tryEval (lib.isDerivation py)) false)
|> lib.filterAttrs (_: py: lib.tryResOr (tryEval py.isPy3) false)
|> lib.mapAttrs (pyAttr: python: pkgs."${pyAttr}Packages")
