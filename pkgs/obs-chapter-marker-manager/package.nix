{
	lib,
	stdenv,
	fetchFromGitHub,
	pkg-config,
	cmake,
	ninja,
	obs-studio,
	curl,
	qt6Packages,
}: stdenv.mkDerivation (self: {
	pname = "obs-chapter-marker-manager";
	version = "1.2.0";

	strictDeps = true;
	__structuredAttrs = true;

	src = fetchFromGitHub {
		owner = "StreamUPTips";
		repo = "obs-chapter-marker-manager";
		rev = "refs/tags/v${self.version}";
		hash = "sha256-IDhGiSm1lVADsCRKWYlK62ad6rTapE/W5UMXm/gu+D8=";
	};

	nativeBuildInputs = [
		qt6Packages.wrapQtAppsHook
		cmake
		ninja
		pkg-config
	];

	buildInputs = [
		obs-studio
		curl
		qt6Packages.qtbase
	];

	meta = {
		homepage = "https://github.com/StreamUPTips/obs-chapter-marker-manager";
		description = "All in one solution for creating and tracking chapter markers in OBS";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl2 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = obs-studio.meta.platforms;
	};
})
