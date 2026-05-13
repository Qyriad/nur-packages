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
	gi-docgen,
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

	# The tests rely on the libraries at the installed paths existing.
	doInstallCheck = true;

	outputs = [ "out" ];

	src = fetchFromGitHub {
		owner = "bhack";
		repo = "pipewire-gobject";
		tag = self.version;
		hash = "sha256-dxW06jWAp5olpaTFTBC6TiLpjyhUf9WrhaU+LUc2qV4=";
	};

	postPatch = ''
		substituteInPlace "tests/test_gir_metadata.py" \
			--replace-fail "libpwg-0.1.so.0" "$out/lib/libpwg-0.1.so.0"
	'';

	pythonEnv = python.withPackages (p: with p; [
		pygobject3
	]);

	nativeBuildInputs = [
		self.pythonEnv
		meson
		ninja
		pkg-config
		gi-docgen
	];

	buildInputs = [
		glib
		pipewire
		gobject-introspection
	];

	installCheckPhase = "mesonCheckPhase";

	mesonBuildType = "debugoptimized";

	meta = {
		description = "Experimental GObject Introspection wrapper for app-facing PipeWire APIs";
		homepage = "https://github.com/bhack/pipewire-gobject";
		license = with lib.licenses; [ mit ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
}))
