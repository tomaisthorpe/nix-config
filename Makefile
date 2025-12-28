.PHONY: help desktop laptop check update clean

# Default target
help:
	@echo "Available targets:"
	@echo "  make desktop  - Rebuild desktop (NixOS)"
	@echo "  make laptop   - Rebuild laptop (NixOS)"
	@echo "  make check    - Run flake check"
	@echo "  make update   - Update flake inputs"
	@echo "  make clean    - Clean build artifacts (>30 days)"

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

clean:
	sudo nix-collect-garbage --delete-older-than 30d
