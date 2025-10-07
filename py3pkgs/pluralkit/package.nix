{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  pythonHooks,
  python3,
  httpx,
  colour,
  pytz,
}: let
  stdenv = stdenvNoCC;
in stdenv.mkDerivation (self: {
  pname = "python-pluralkit";
  version = "1.2.1";

  outputs = [ "out" "dist" ];

  src = fetchFromGitHub {
    owner = "almonds0166";
    repo = "pluralkit.py";
    rev = "a261c373e253f3b166ce8f2a81a427ba81b30927";
    hash = "sha256-PsgCsLD+qJjlkq2Z9pDlvkzyLq7ayDdw9dBYTH0js78=";
  };

  propagatedBuildInputs = [
    httpx
    colour
    pytz
  ];

  nativeBuildInputs = (pythonHooks python3).asList;

  meta = {
    description = "A Python library for the PluralKit API";
    homepage = "https://github.com/almonds0166/pluralkit.py";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ qyriad ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
