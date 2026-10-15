{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	copyDesktopItems,
	makeDesktopItem,
	pkg-config,
	cmake,
	ninja,
	fd,
	qt6Packages,
}: lib.callWith' qt6Packages ({
	qtbase,
	qtdeclarative,
	qtwebsockets,
	qttools,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "magic-pods-linux";
	version = "2026-10-10";

	src = fetchFromGitHub {
		owner = "haileyok";
		repo = "MagicPodsLinux";
		rev = "4763c74188a1be7360204afb684fc8898edfe08d";
		fetchSubmodules = true;
		hash = "sha256-30fDOewIwDYhHaDoOSHfGJ6dtDvRaq7usruy1J6Xwf0=";
	};

	nativeBuildInputs = [
		copyDesktopItems
		pkg-config
		cmake
		ninja
		fd
		qttools
	];

	buildInputs = [
		qtbase
		qtdeclarative
		qtwebsockets
		qttools
	];

	# Upstream's install goes for the fully self-contained Qt bundle route.
	# But we are Nix.
	# So let's just install the things ourselves.
	dontUseNinjaInstall = true;

	desktopItemMagicpods = makeDesktopItem {
		name = "app.magicpods";
		desktopName = "MagicPods";
		exec = "magicpods";
		icon = "magicpods";
		comment = "Control center for Bluetooth headphones";
		categories = [ "Utility" ];
		startupWMClass = "MagicPods";
	};
	desktopItems = [ self.desktopItemMagicpods ];

	installPhase = lib.dedent ''
		runHook preInstall
		install -Dm755 "$NIX_BUILD_TOP/$sourceRoot/$cmakeBuildDir/magicpods" "$out/bin/magicpods"
		install -Dm644 \
			"$NIX_BUILD_TOP/$sourceRoot/src/app/qml/assets/icons/mp-logo-color.svg" \
			"$out/share/icons/hicolor/scalable/apps/magicpods.svg"

		runHook postInstall
	'';

	# We'll just add DT_NEEDED for the Qt base plugins ourselves.
	dontWrapQtApps = true;

	qtBasePlugins = "${qtbase}/${qtbase.qtPluginPrefix}";

	postFixup = lib.dedent ''
		chmod -v u+w "$out/bin/magicpods"
		fd -t f -F "${stdenv.hostPlatform.extensions.sharedLibrary}" "$qtBasePlugins" \
			--threads=1 \
			--exec patchelf "$out/bin/magicpods" --add-needed "{}" ";"
	'';

	meta = {
		homepage = "https://github.com/haileyok/MagicPodsLinux/tree/hailey/mac-parity";
		description = "MagicModsLinux, mac-parity branch";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ gpl3Only ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		# Qt6WebSockets is considered Not Found by CMake <6.11 ¯\_(ツ)\_/¯
		broken = lib.versionOlder qtwebsockets.version "6.11.0";
		mainProgram = "magicpods";
	};
}))
