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
|> stdenvAdapters.addAttrsToDerivation (prev: {
	mesonFlags = [
		"-Dc_link_args=-fuse-ld=lld"
		"-Dcpp_link_args=-fuse-ld=lld"
	] ++ prev.mesonFlags or [ ];
	cmakeFlags = [
		"-DCMAKE_EXE_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_SHARED_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_STATIC_LINKER_FLAGS_INIT=-fuse-ld=lld"
		"-DCMAKE_MODULE_LINKER_FLAGS_INIT=-fuse-ld=lld"
	] ++ prev.cmakeFlags or [ ];
})
