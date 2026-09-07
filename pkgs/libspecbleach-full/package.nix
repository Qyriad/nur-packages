{
	lib,
	stdlib,
	stdenv,
	fetchFromGitHub,
	pkg-config,
	cmake,
	ninja,
}: stdlib.makePackage stdenv (finalAttrs: let
	self = finalAttrs.finalPackage;
in {
	pname = "libspecbleach-full";
	version = "0.4.1";

	src = fetchFromGitHub {
		owner = "lucianodato";
		repo = "libspecbleach";
		tag = "v${self.version}";
		hash = "sha256-rZdlrsTeVNZ6hzUBe57fWx4NqQYL/MdVUiYmQUDeoJQ=";
	};

	nativeBuildInputs = [
		pkg-config
		cmake
		ninja
	];

	cmakeFlags = [
		(lib.cmakeBool "SPECBLEACH_BUILD_EXTRAS" true)
		(lib.cmakeBool "ENABLE_TESTS" self.doCheck)
		# HACK: libspecbleach manually joins CMAKE_INSTALL_LIBDIR
		# and CMAKE_INSTALL_INCLUDEDIR onto $prefix, but Nixpkgs configures
		# both of those to be absolute paths. The correct solution is for libspecbleach's
		# CMake files to use CMAKE_INSTALL_FULL_*DIR here:
		# https://github.com/lucianodato/libspecbleach/blob/ab4ae8b4be74f5c52c5a3386a6d9bbea29fbd129/CMakeLists.txt#L430-L431
		# However, we can hack around this by *not* splitting the libraries and headers
		# into different Nix derivation outputs, allowing $libdir and $includedir
		# to be genuinely relative to $prefix.
		"-DCMAKE_INSTALL_LIBDIR=lib"
		"-DCMAKE_INSTALL_INCLUDEDIR=include"
	];

	meta = {
		homepage = "https://github.com/lucianodato/libspecbleach";
		description = "C library for audio noise reduction and other spectral effects (w/ libspecbleach-extras)";
		maintainers = with lib.maintainers; [ qyriad ];
		license = with lib.licenses; [ lgpl21 ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
	};
})
