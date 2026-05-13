{
	lib,
	python3Packages,
	fetchFromGitHub,
	meson,
	ninja,
	pkg-config,
	glib,
	pipewire,
	gobject-introspection,
}: lib.callWith' python3Packages ({
	python,
	stdenv,
}: stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "pipewire-gobject";
	version = "0.3.8";

	strictDeps = true;
	__structuredAttrs = true;

	outputs = [ "out" ];

	src = fetchFromGitHub {
		owner = "bhack";
		repo = "pipewire-gobject";
		tag = self.version;
		hash = "sha256-dxW06jWAp5olpaTFTBC6TiLpjyhUf9WrhaU+LUc2qV4=";
	};

	nativeBuildInputs = [
		python
		meson
		ninja
		pkg-config
	];

	buildInputs = [
		glib
		pipewire
		gobject-introspection
	];

	# mesonFlags = [
	# 	(lib.mesonBool "wheel" true)
	# ];

	meta = {
		description = "Experimental GObject Introspection wrapper for app-facing PipeWire APIs";
		homepage = "https://github.com/bhack/pipewire-gobject";
		license = with lib.licenses; [ mit ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
}))
