/** Experiments in argument validation error messages.
 */
{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}: let
	inherit (self.ansi) stylizeHint;
	inherit (self) dedent;
in {
	mkHint = text: "${stylizeHint "HINT"}: ${dedent text}";

	/**
	 * We keep the real assertion, e.g. `assert lib.isList someArg`, at the caller.
	 * This is a trade off for the error message. The error itself will be simply
	 * `error: assertion failed`, which is not terribly helpful.
	 * But if the assertion expression is not abstracted, then the line of code
	 * that trace will point to will be descriptive, e.g.:
	 *   assert lib.isFunction f; true
	 *   ^
	 * And because with `addErrorContext` the immediate trace before that will have
	 * "while validating `f` arg to `someFunction`.
	 *
	 * This allows (relatively) concisely improving type correctness while also
	 * meaningfully improving the error messages, without introducing e.g., the
	 * full module type system.
	 */
	validateArg =
		functionName:
		argumentName:
		validationExpr:
	lib.deepSeq (
		validationExpr
		|> lib.addErrorContext "while validating `${argumentName}` argument to `${functionName}`"
	) true;

	/** Adds error context `msg` if `cond` evaluates to true.
	 * Otherwise, does nothing, but does shallowly evaluate `msg`.
	 */
	optionalErrorContext = cond: msg: if cond then lib.addErrorContext msg else lib.seq msg;
}
