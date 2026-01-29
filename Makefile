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
# Includes 'fix-windows' to ensure the script is executable and clean
install: fix-windows
	@echo ":: INITIALIZING TRASHCAN NODE ::"
	@if [ -f "$(HW_CFG)" ]; then \
		echo "[*] Cloning hardware identity..."; \
		cp "$(HW_CFG)" "$(TGT_HW)"; \
		git add "$(TGT_HW)"; \
	else \
		echo "!! CI/CD Mode: Using template hardware config."; \
	fi
	@echo "[*] Building System..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo ":: DEPLOY COMPLETE. ::"

# 3. MAINTENANCE
# Includes 'fix-windows' so the CLI tool is always clean before running
sync: fix-windows
	@./bin/macpronix sync

upgrade: fix-windows
	@./bin/macpronix upgrade

status: fix-windows
	@./bin/macpronix status

# 4. UTILITIES
# Removes Windows Line Endings (\r) and sets executable permissions
fix-windows:
	@chmod +x bin/macpronix
	@sed -i 's/\r$$//' bin/macpronix || true

# 5. CI/CD VERIFICATION
check:
	@echo "[*] Verifying Flake Integrity..."
	@nix flake check