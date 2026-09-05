{
	lib,
	stdenv,
	stdlib,
	rustHooks,
	rustPlatform,
	cargo,
	fetchFromGitHub,
	writeShellScriptBin,
	mkAbsoluteDylibsHook,
	nasm,
	cargo-about,
	wayland,
	libxkbcommon,
	dav1d,
	libheif,
	gdk-pixbuf,
	libglvnd,
	mesa,
	udev,
	vulkan-loader,
	xz,
	zlib,
	zstd,
}: lib.callWith' rustPlatform ({
	fetchCargoVendor,
}: let
	inherit (lib.mkPlatformGetters stdenv.hostPlatform)
		getLibrary
	;
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalLinux
	;
in stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "simp";
	version = "3.11.0";

	src = fetchFromGitHub {
		owner = "Kl4rry";
		repo = "simp";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-Yh4k+cnNDX/DUoguPIJKboJf/HoxBIRGltf3jOS6790=";
	};

	# simp's build.rs calls `git rev-parse`. We'll just fake it.
	fakeGit = writeShellScriptBin "git" ''
		if [[ "$1" == "rev-parse" ]]; then
			echo "v${self.version}"
		else
			echo "fake git script called with unknown arguments: $@"
			exit 1
		fi
	'';

	cargoDeps = fetchCargoVendor {
		name = lib.suffixName self "cargo-deps";
		inherit (self) src;
		hash = "sha256-lvo4ibneJEvmbbfg3nxAGtPbgahKs/8H8ZOFYnqP058=";
	};

	absoluteDylibsHook = lib.optionalDrvAttr stdenv.isLinux (mkAbsoluteDylibsHook {
		inherit (self) name;
		# Wow, 7 months later and this is some of the wildest Nix code we've written.
		runtimeDependenciesFor."$out/bin/simp" = map (lib.splatTo getLibrary) [
			[ wayland "wayland-client" ]
			[ libxkbcommon "xkbcommon" ]
			[ libglvnd "GL" ]
			[ libglvnd "EGL" ]
			[ vulkan-loader "vulkan" ]
			[ zlib "z" ]
			[ zstd "zstd" ]
			[ xz "lzma" ]
		];
	});

	nativeBuildInputs = rustHooks.asList ++ [
		cargo
		self.fakeGit
		cargo-about
		nasm
	] ++ optionalLinux [
		self.absoluteDylibsHook
	];

	buildInputs = [
		dav1d
		libheif
		gdk-pixbuf
		libglvnd
		vulkan-loader
		zlib
		zstd
		xz
	] ++ optionalLinux [
		wayland
		libxkbcommon
		mesa
		udev
	];

	meta = {
		mainProgram = "simp";
		broken = true;
	};
}))
