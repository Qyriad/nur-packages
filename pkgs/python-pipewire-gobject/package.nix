{
	lib,
	pipewire-gobject,
}: pipewire-gobject.overrideAttrs (final: prev: {
	pname = "python-pipewire-gobject";
	mesonFlags = prev.mesonFlags or [ ] ++ [
		(lib.mesonBool "wheel" true)
	];
})
