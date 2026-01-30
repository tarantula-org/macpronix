# --- MACPRONIX INFRASTRUCTURE ---

# 1. Environment
FLAKE   := .#trashcan
HW_CFG  := /etc/nixos/hardware-configuration.nix
TGT_HW  := hosts/trashcan/hardware.nix

# --- PHONY TARGETS ---
.PHONY: all install sync upgrade clean check fix-windows

# 1. DEFAULT
all: status

# 2. BOOTSTRAP (First Run)
install: fix-windows
	@echo ":: INITIALIZING TRASHCAN NODE ::"
	@if [ -f "$(HW_CFG)" ]; then \
		echo "[*] Cloning hardware identity..."; \
		cp "$(HW_CFG)" "$(TGT_HW)"; \
		git add -f "$(TGT_HW)"; \
	else \
		echo "!! CI/CD Mode: Using template hardware config."; \
	fi
	@echo "[*] Building System..."
	@sudo nixos-rebuild switch --flake $(FLAKE) --impure
	@echo ":: DEPLOY COMPLETE. ::"

# 3. MAINTENANCE
sync: fix-windows
	@./bin/macpronix sync

upgrade: fix-windows
	@./bin/macpronix upgrade

status: fix-windows
	@./bin/macpronix status

# 4. UTILITIES
# Added recursive sed to ensure all nix files are sanitized for the evaluator
fix-windows:
	@chmod +x bin/macpronix
	@find . -type f -name "*.nix" -exec sed -i 's/\r$$//' {} +
	@sed -i 's/\r$$//' bin/macpronix || true

# 5. CI/CD VERIFICATION
check:
	@echo "[*] Verifying Version File..."
	@test -f VERSION.txt || (echo "Missing VERSION.txt" && exit 1)
	@echo "[*] Verifying Flake Integrity..."
	@nix flake check