# --- MACPRONIX INFRASTRUCTURE ---
# Zero-Touch Configuration System

# 1. ENVIRONMENT
FLAKE   := .#trashcan
HW_CFG  := /etc/nixos/hardware-configuration.nix
TGT_HW  := hosts/trashcan/hardware.nix

# --- PHONY TARGETS ---
.PHONY: all install sync upgrade clean check fix-windows validate

# 1. DEFAULT
all: status

# 2. BOOTSTRAP (First Run)
# This target handles dynamic hardware injection for any Mac Pro 6,1 node
install: fix-windows validate
	@echo ":: INITIALIZING TRASHCAN NODE ::"
	@echo ""
	@if [ -f "$(HW_CFG)" ]; then \
		echo "[*] Hardware Identity Detected"; \
		echo "[*] Extracting UUIDs from $(HW_CFG)..."; \
		ROOT_UUID=$$(grep -oP 'device = "/dev/disk/by-uuid/\K[^"]+' $(HW_CFG) | head -n1); \
		BOOT_UUID=$$(grep -oP 'device = "/dev/disk/by-uuid/\K[^"]+' $(HW_CFG) | sed -n 2p); \
		SWAP_UUID=$$(grep -oP 'device = "/dev/disk/by-uuid/\K[^"]+' $(HW_CFG) | tail -n1); \
		echo "   Root: $$ROOT_UUID"; \
		echo "   Boot: $$BOOT_UUID"; \
		echo "   Swap: $$SWAP_UUID"; \
		echo ""; \
		echo "[*] Injecting UUIDs into hardware.nix..."; \
		sed -i "s|/dev/disk/by-uuid/[a-f0-9-]*\"; # Root|/dev/disk/by-uuid/$$ROOT_UUID\";|" $(TGT_HW) || true; \
		sed -i "s|/dev/disk/by-uuid/[A-F0-9-]*\"; # Boot|/dev/disk/by-uuid/$$BOOT_UUID\";|" $(TGT_HW) || true; \
		sed -i "s|/dev/disk/by-uuid/[a-f0-9-]*\"; } ]; # Swap|/dev/disk/by-uuid/$$SWAP_UUID\"; } ];|" $(TGT_HW) || true; \
		git add -f "$(TGT_HW)"; \
	else \
		echo "[!] No hardware-configuration.nix found"; \
		echo "[!] CI/CD Mode: Using template hardware config"; \
	fi
	@echo ""
	@echo "[*] Running Pre-Flight Checks..."
	@nix flake check --show-trace || (echo "[!] Flake validation failed" && exit 1)
	@echo ""
	@echo "[*] Building System (Test Mode)..."
	@sudo nixos-rebuild test --flake $(FLAKE) --impure || (echo "[!] Build failed" && exit 1)
	@echo ""
	@echo "[*] Build Verified. Installing to Bootloader..."
	@sudo nixos-rebuild boot --flake $(FLAKE) --impure
	@echo ""
	@echo ":: DEPLOY COMPLETE ::"
	@echo ":: REBOOT to activate the new configuration ::"

# 3. MAINTENANCE
sync: fix-windows
	@./bin/macpronix sync

upgrade: fix-windows
	@./bin/macpronix upgrade

status: fix-windows
	@./bin/macpronix status

# 4. HYGIENE & VALIDATION
# CRITICAL: This target prevents Windows line endings from poisoning the Nix evaluator
# It recursively sanitizes ALL .nix files and executables
fix-windows:
	@echo "[*] Sanitizing line endings..."
	@find . -type f -name "*.nix" -exec sed -i 's/\r$$//' {} + 2>/dev/null || true
	@find . -type f -path "*/bin/*" -exec sed -i 's/\r$$//' {} + 2>/dev/null || true
	@sed -i 's/\r$$//' Makefile 2>/dev/null || true
	@chmod +x bin/macpronix 2>/dev/null || true

# Validate flake integrity without building
validate:
	@echo "[*] Validating Flake Structure..."
	@nix flake check --show-trace

# 5. CI/CD VERIFICATION
check: fix-windows
	@echo "[*] Verifying Version File..."
	@test -f VERSION.txt || (echo "[!] Missing VERSION.txt" && exit 1)
	@echo "[*] Verifying Flake Integrity..."
	@nix flake check --show-trace
	@echo "[*] Verifying CODEOWNERS..."
	@test -f .github/CODEOWNERS || (echo "[!] Missing CODEOWNERS" && exit 1)
	@echo ""
	@echo "[✓] All Checks Passed"

# 6. CLEANUP
clean:
	@echo "[*] Removing Build Artifacts..."
	@rm -rf result result-*
	@echo "[✓] Clean Complete"