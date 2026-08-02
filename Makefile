.PHONY: help desktop laptop check update update-nvim-plugins clean

# Default target
help:
	@printf '%s\n' "Available targets:"
	@printf '  %-26s %s\n' "make desktop" "Rebuild desktop (NixOS)"
	@printf '  %-26s %s\n' "make laptop" "Rebuild laptop (NixOS)"
	@printf '  %-26s %s\n' "make check" "Run flake check"
	@printf '  %-26s %s\n' "make update" "Update flake inputs"
	@printf '  %-26s %s\n' "make update-nvim-plugins" "Update Neovim plugins and lockfile"
	@printf '  %-26s %s\n' "make clean" "Clean build artifacts (>30 days)"

# NixOS systems
desktop:
	sudo nixos-rebuild switch --flake .#desktop

laptop:
	sudo nixos-rebuild switch --flake .#laptop

# Utilities
check:
	nix flake check

update:
	nix flake update

update-nvim-plugins:
	./scripts/update-nvim-plugins

clean:
	sudo nix-collect-garbage --delete-older-than 30d
