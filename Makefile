# --- MACPRONIX INFRASTRUCTURE ---

# 1. Environment
FLAKE   := .#trashcan
HW_CFG  := /etc/nixos/hardware-configuration.nix
TGT_HW  := hosts/trashcan/hardware.nix

# --- PHONY TARGETS ---
.PHONY: all install sync upgrade clean check

# 1. DEFAULT
all: status

# 2. BOOTSTRAP (First Run)
install:
	@echo ":: INITIALIZING TRASHCAN NODE ::"
	@if [ -f "$(HW_CFG)" ]; then \
		echo "[*] Cloning hardware identity..."; \
		cp "$(HW_CFG)" "$(TGT_HW)"; \
		git add "$(TGT_HW)"; \
	else \
		echo "!! Error: Hardware config not found. Run 'nixos-generate-config' first."; \
		exit 1; \
	fi
	@echo "[*] Building System..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo ":: DEPLOY COMPLETE. Reboot advised. ::"

# 3. MAINTENANCE
sync:
	@./bin/macpronix sync

upgrade:
	@./bin/macpronix upgrade

status:
	@./bin/macpronix status

# 4. CI/CD VERIFICATION
check:
	@echo "[*] Verifying Flake Integrity..."
	@nix flake check