{
	lib,
	stdlib,
	stdenv,
	fetchFromForgejo ? fetchFromGitea,
	fetchFromGitea,
	installShellFiles,
	groff,
	unixtools,
	fd,
	alsa-lib,
	fmt,
	icu,
	versionCheckHook,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "midiminder";
	version = "1.0.1";

	src = fetchFromForgejo {
		domain = "forge.glyphic.com";
		owner = "mark";
		repo = "midiminder";
		tag = "${self.version}";
		hash = "sha256-l4NxKZOqciW31nijaOHcFMEzatZROPrb6DjupGScfrw=";
	};

	hardeningEnable = lib.optionals (lib.versionAtLeast lib.version "25.11") [
		"glibcxxassertions"
		"libcxxhardeningextensive"
	];

	postPatch = lib.dedent ''
		substituteInPlace "$NIX_BUILD_TOP/$sourceRoot/midiminder.service" \
			--replace-fail "/usr/" "$out/"
		# Comment out the `EnvironmentFile=/etc/environment` line, as it doesn't conventionally exist on NixOS.
		substituteInPlace "$NIX_BUILD_TOP/$sourceRoot/midiminder.service" \
			--replace-fail "EnvironmentFile=/etc/environment" "#EnvironmentFile=/etc/environment"
	'';

	makeFlags = [
		"PREFIX=${placeholder "out"}"
	];

	env.CPPFLAGS = lib.escapeShellArgs [
		# Our C++ headers don't provide `std::system_error` in `<stdexcept>`.
		"-include${./missing_includes.hpp}"
	];

	nativeBuildInputs = [
		installShellFiles
		groff
		unixtools.col
		fd
	];

	buildInputs = [
		alsa-lib
		fmt
		icu
	];

	postInstall = ''
		# /man in the source checkout has the manpage source files like `midiminder-daemon.8.txt`,
		# as well as their generated counterparts `midiminder-daemon.8`.
		# The Makefile is set to remake them based on those .txt files, but the post-clone
		# timestamps are considered up-to-date.
		# So let's just unconditionally remake them, and then install files that end in
		# a period and a digit (to not catch the .txt sources).
		make -B format-man-pages
		fd -t f '.*\.\d$' "$NIX_BUILD_TOP/$sourceRoot/man" | while IFS= read -r manPage; do
			installManPage "$manPage"
		done

		# The systemd service.
		install --verbose -Dm644 --target-directory="$out/lib/systemd/system" "$NIX_BUILD_TOP/$sourceRoot/midiminder.service"

		# And example rules.
		fd -t f . "$NIX_BUILD_TOP/$sourceRoot/rules" | while IFS= read -r exampleRule; do
			install --verbose -Dm644 --target-directory="$out/share/doc/midiminder/examples" "$exampleRule"
		done

		# Finally, the Bash completions.
		fd -t f . "$NIX_BUILD_TOP/$sourceRoot/bash-completion" | while IFS= read -r completionScript; do
			installShellCompletion --bash "$completionScript"
		done
	'';

	nativeInstallCheckInputs = [
		versionCheckHook
	];

	meta = {
		homepage = "https://forge.glyphic.com/mark/midiminder";
		description = "ALSA utility to keep your MIDI devices connected";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ bsd2 ];
		platforms = lib.platforms.linux;
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "midiminder";
	};
})
