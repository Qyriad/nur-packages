{
	lib,
	stdenv,
	fetchzip,
	qt6Packages,
	alsa-lib,
	fluidsynth,
	libjack2,
	cmake,
	ninja,
	pkg-config,
	# All of these are theoretically optional:
	libsysprof-capture,
	libsndfile,
	pipewire,
	flac,
	libogg,
	libvorbis,
	libopus,
	libmpg123,
	libpulseaudio,
}: lib.callWith' qt6Packages ({
	qtbase,
	qttools,
	qtsvg,
}: stdenv.mkDerivation (self: {
	pname = "qsynth";
	version = "1.0.3";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchzip {
		url = "mirror://sourceforge/qsynth/qsynth-${self.version}.tar.gz";
		hash = "sha256-HvF0ITBKLINQ+cQJzcGsNsP/ks2CbypdWhDW00eigZg=";
	};

	outputs = [ "out" "man" ];

	nativeBuildInputs = [
		cmake
		ninja
		pkg-config
	];

	buildInputs = [
		alsa-lib
		fluidsynth
		libjack2
		qtbase
		qttools
		qtsvg
		libsysprof-capture
		libsndfile
		pipewire
		flac
		libogg
		libvorbis
		libopus
		libmpg123
		libpulseaudio
	];

	cmakeBuildType = "RelWithDebInfo";
	# Works fine without.
	dontWrapQtApps = true;

	# This should probably be in `meta` but Nixpkgs doesn't have a way to
	# add more attributes that `config.checkMeta = true;` will recognize.
	passthru.optionalFeatures = {
		inherit
			libsysprof-capture
			libsndfile
			pipewire
			flac
			libogg
			libvorbis
			libopus
			libmpg123
			libpulseaudio
		;
	};

	meta = {
		description = "Fluidsynth GUI";
		longDescription = self.finalPackage.meta.description
		+ "\n\nOptional features: "
		+ lib.mkOptionalFeaturesDesc self.finalPackage.optionalFeatures;
		mainProgram = "qsynth";
		homepage = "https://sourceforge.net/projects/qsynth";
		license = with lib.licenses; [ gpl2Plus] ;
		maintainers = with lib.maintainers; [ qyriad ];
		platforms = lib.platforms.linux;
	};
}))
