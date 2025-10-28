{
	lib,
	python3,
	xonsh,
	fetchFromGitHub,
}:

let
	inherit (python3.pkgs)
		buildPythonPackage
		setuptools
		wheel
		poetry-core
		prompt-toolkit
		setuptools-scm
	;

	# Compatibility with NixOS/nixpkgs#282368 (a30ae78435b7c481233601eea523b9340ca0760f).
	# The wrapper breaks importing xonsh as a library, which means it won't work in
	# nativeCheckInputs. pkgs.xonsh-unwrapped was removed in the above PR, so to access
	# the underlying xonsh library we call overridePythonAttrs to get the arguments
	# buildPythonApplication was originally called with, and then call buildPythonApplication
	# again with those arguments.
	xonshUnwrapped = let
		# Make a version of xonsh that has the original buildPythonApplication args
		# as a `passthru` attr.
		withPassthruArgs = xonsh.overridePythonAttrs (self: {
			passthru = self.passthru // {
				pythonAttrs = self;
			};
		});

		# Then get that attribute,
		pythonArgs = withPassthruArgs.pythonAttrs;
	in
		# And pass it as buildPythonApplication args.
		python3.pkgs.buildPythonApplication pythonArgs;

	pname = "xontrib-abbrevs";
	version = "0.1.0";
in
	buildPythonPackage {
		inherit pname version;

		src = fetchFromGitHub {
			name = "${pname}-source";
			owner = "xonsh";
			repo = "xontrib-abbrevs";
			rev = "refs/tags/v${version}";
			hash = "sha256-JxH5b2ey99tvHXSUreU5r6fS8nko4RrS/1c8psNbJNc=";
		};

		format = "pyproject";

		nativeBuildInputs = [
			setuptools
			wheel
			poetry-core
			setuptools-scm
		];

		nativeCheckInputs = [
			xonshUnwrapped
			prompt-toolkit
		];

		meta = {
			description = "Xonsh extension for using direnv";
			homepage = "https://github.com/74th/xonsh-direnv";
			license = lib.licenses.mit;
		};

	}
