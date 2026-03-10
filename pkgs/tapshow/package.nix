{
	lib,
	stdenv,
	fetchFromGitHub,
	fetchGoModules,
	goHooks,
	pkg-config,
	glib,
	cairo,
	gobject-introspection,
	graphene,
	gdk-pixbuf,
	pango,
	gtk4,
}: stdenv.mkDerivation (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "tapshow";
	version = "0.3.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "hmnd";
		repo = "tapshow";
		tag = "v${self.version}";
		hash = "sha256-QzN2OVgcmC7m63BwY+B/hnkW5YtZjNmrdeo25Qryq94=";
	};

	goModules = fetchGoModules {
		inherit (self) name;
		inherit (self) src;
		hash = "sha256-UF3Qsu1BywJrKSNrZUbxChsS0qjbMo2nlOK5zcLiirY=";
	};

	nativeBuildInputs = goHooks.asList ++ [
		pkg-config
	];

	buildInputs = [
		glib
		cairo
		gobject-introspection
		graphene
		gdk-pixbuf
		pango
		gtk4
	];

	passthru = {
		fromHead = lib.mkHeadFetch { inherit self; };
	};

	meta = {
		homepage = "https://github.com/hmnd/tapshow";
		description = "Minimal keystroke visualizer for Wayland";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ mit ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		broken = lib.versionOlder goHooks.go.version "1.25.5";
		platforms = lib.platforms.linux;
		mainProgram = "tapshow";
	};
})
