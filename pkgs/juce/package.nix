{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	pkg-config,
	cmake,
	ninja,
	alsa-lib,
	jack2 ? null,
	ladspa-sdk ? null,
	curl ? null,
	fontconfig ? null,
	freetype ? null,
	libx11 ? libX11,
	libX11 ? throw "older Nixpkgs has libX11",
	libxcomposite ? libXcomposite,
	libXcomposite ? throw "older Nixpkgs has libXcomposite",
	libxcursor ? libXcursor,
	libXcursor ? null,
	libxext ? libXext,
	libXext ? throw "older Nixpkgs has libXext",
	libxinerama ? libXinerama,
	libXinerama ? null,
	libxrandr ? libXrandr,
	libXrandr ? null,
	libxrender ? libXrender,
	libXrender ? null,
	libxi ? null,
	webkitgtk_4_1 ? null,
	# --
	# Vaguely wanted by glib
	libsysprof-capture ? null,
	pcre2 ? null,
	util-linux ? null,
	# --
	libGLU,
	libGL,
	mesa,
	versionCheckHook,
	withExtras ? true,
	ripgrep,
	sd,
	fd,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
	inherit (lib.mkPlatformPredicates stdenv.hostPlatform)
		optionalLinux
	;
in {
	pname = "juce";
	version = "9.0.2";

	src = fetchFromGitHub {
		owner = "juce-framework";
		repo = "JUCE";
		tag = "${self.version}";
		hash = "sha256-N9n/ptqNI7jQLKZ28Xm541M9gUDJPMLS6Dgj1lNVJ3g=";
	};

	# Upstream uses install directories like `lib/pkgconfig/JUCE-9.0.2/…`
	# But we want `lib/pkgconfig/juce/…`
	# They also use `bin/JUCE-9.0.2/…`, but we want `bin/…`.
	# So we do that one first, and then the more general case.
	postPatch = lib.dedent ''
		fd '(CMakeLists.txt)|(\.cmake)' "$NIX_BUILD_TOP/$sourceRoot" --exec sd 'bin/JUCE-\$\{JUCE_VERSION\}' 'bin' '{}'

		fd CMakeLists.txt "$NIX_BUILD_TOP/$sourceRoot" --exec sd '\bJUCE-\$\{JUCE_VERSION\}' 'juce' '{}'
		fd \.cmake "$NIX_BUILD_TOP/$sourceRoot" --exec sd '\bJUCE-\$\{JUCE_VERSION\}' 'juce' '{}'
	'';

	inherit withExtras;

	nativeBuildInputs = [
		pkg-config
		cmake
		ninja
		ripgrep
		sd
		fd
	];

	cmakeFlags = [
		(lib.cmakeBool "JUCE_BUILD_EXTRAS" self.withExtras)
		(lib.cmakeBool "JUCE_JACK" (jack2 != null))
		(lib.cmakeBool "JUCE_PLUGINHOST_LADSPA" (ladspa-sdk != null && stdenv.hostPlatform.isLinux))
		(lib.cmakeBool "JUCE_USE_CURL" (curl != null))
		(lib.cmakeBool "JUCE_USE_FONTCONFIG" (fontconfig != null))
		(lib.cmakeBool "JUCE_USE_FREETYPE" (freetype != null))
		(lib.cmakeBool "JUCE_USE_XCURSOR" (libxcursor != null))
		(lib.cmakeBool "JUCE_USE_XINERAMA" (libxinerama != null))
		(lib.cmakeBool "JUCE_USE_XRANDR" (libxrandr != null))
		(lib.cmakeBool "JUCE_USE_XRENDER" (libxrender != null))
		(lib.cmakeBool "JUCE_USE_XINPUT" (libxi != null))
		(lib.cmakeBool "JUCE_WEB_BROWSER" (webkitgtk_4_1 != null))
		"-DJUCE_INSTALL_DESTINATION=${placeholder "out"}/lib/cmake/juce"
	];

	buildInputs = [
		jack2
		curl
		fontconfig
		freetype
		mesa
	] ++ optionalLinux [
		alsa-lib
		ladspa-sdk
		webkitgtk_4_1
		libx11
		libxcomposite
		libxcursor
		libxext
		libxinerama
		libxrandr
		libxrender
		libxi
		libGLU
		libGL
		# pkg-config wants these via glib-2.0, but it won't error without the,.
		libsysprof-capture
		pcre2
		util-linux
	];

	#preFixup = lib.dedent ''
	#	pushd "$out/bin/juce"
	#	mv * ../
	#	rmdir "$out/bin/juce"
	#	popd
	#'';

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	versionCheckProgramArg = "version";
	# Needed for older Nixpkgs, as the command name is not pname.
	versionCheckProgram = "${placeholder "out"}/bin/${self.meta.mainProgram}";

	meta = {
		homepage = "https://github.com/juce-framework/JUCE";
		description = "An open-source cross-platform C++ application framework for desktop and mobile applications, including VST, VST3, AU, AUv3, LV2 and AAX audio plug-ins";
		longDescription = lib.dedent ''
			Compared to Nixpkgs, this one works on Darwin.
		'';
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ agpl3Only ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		platforms = with lib.platforms; linux ++ darwin;
		mainProgram = "juceaide";
	};
})
