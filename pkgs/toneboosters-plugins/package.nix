{
	lib,
	stdlib,
	stdenv,
	fetchzip,
	autoPatchelfHook,
	alsa-lib,
	fontconfig,
	freetype,
	libGL,
	curl,
	libgcc,
	fd,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "toneboosters-plugins";
	version = "2.1.8";

	src = fetchzip {
		url = "https://www.toneboosters.com/downloads/TB_Archive_v${self.version}_linux.tar.gz";
		hash = "sha256-3PVtjR9UvV1k038w8Mai0/NQ8ItWgXiwBV8mdjvRg0Q=";
		# It blocks user-agent "curl".
		curlOptsList = [ "-A" "Nixpkgs ${lib.version} ${builtins.nixVersion}" ];
		stripRoot = false;
	};

	installPhase = lib.dedent ''
		mkdir -p "$out/bin" "$out/lib/vst3" "$out/lib/vst"
		fd --type=executable . "$NIX_BUILD_TOP/$sourceRoot/app" --exec install -Dm644 "{}" "$out/bin/{}"
		fd --max-depth=1 . "$NIX_BUILD_TOP/$sourceRoot/vst3" --exec cp -r "{}" "$out/lib/vst3/"
		fd --max-depth=1 . "$NIX_BUILD_TOP/$sourceRoot/vst" --exec cp -r "{}" "$out/lib/vst/"
	'';

	buildInputs = [
		alsa-lib
		fontconfig
		freetype
		libGL
		curl
		# NOTE: `lib.getLib libgcc` is incorrect.
		# That gets the "libgcc" output, but we need the "lib" output, for libatomic and libstdc++.
		libgcc.lib
	];

	nativeBuildInputs = [
		autoPatchelfHook
		fd
	];

	meta = {
		homepage = "https://www.toneboosters.com/";
		description = "Suite of plugins by ToneBoosters";
		longDescription = lib.dedent ''
			Includes the following plugins:
				- TB_Barricade_v4
				- TB_BitJuggler_v1
				- TB_Compressor_v4
				- TB_DualVCF_v1
				- TB_Enhancer_v1
				- TB_Equalizer_v4
				- TB_Flowtones_v1
				- TB_GonioMeter_v1
				- TB_Lowtone_v1
				- TB_MBC_v1
				- TB_Morphit_v1
				- TB_ReelBus_v4
				- TB_Reverb_v4
				- TB_Sibalance_v4
				- TB_Spectrogram_v1
				- TB_VoicePitcher_v4
				- TB Equalizer Pro
		'';
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ unfree ];
		platforms = [ "x86_64-linux" ];
		sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
	};
})
