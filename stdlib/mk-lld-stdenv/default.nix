{
	pkgs,
	lib,
	stdenvAdapters,
	llvmPackages,
}: {
	stdenv,
}: stdenv.cc.override {
	bintools = llvmPackages.bintools;
}
|> stdenvAdapters.overrideCC llvmPackages.stdenv
|> stdenvAdapters.addAttrsToDerivation {
	mesonFlags = [
		"-Dc_link_args=-fuse-ld=lld"
		"-Dcpp_link_args=-fuse-ld=lld"
	];
	cmakeFlags = [
		"-DCMAKE_EXE_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_SHARED_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_STATIC_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_MODULE_LINKER_FLAGS_INIT=-fuse-ld=lld"
	];
}
