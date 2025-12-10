{
	stdenvAdapters,
	wrapBintoolsWith,
	llvmPackages,
}: llvmPackages.stdenv.cc.override {
	inherit (llvmPackages) bintools;
}
|> stdenvAdapters.overrideCC llvmPackages.stdenv
