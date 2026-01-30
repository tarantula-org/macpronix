# --- MACPRONIX INFRASTRUCTURE ---
# v4.5.0 "Silicon Truth"

# 1. ENVIRONMENT
FLAKE   := .#trashcan
TGT_HW  := hosts/trashcan/hardware.nix

# --- PHONY TARGETS ---
.PHONY: all install sync upgrade clean check fix-windows validate

# 1. DEFAULT
all: status

# 2. BOOTSTRAP (Zero-Touch)
install: fix-windows validate
	@echo ":: INITIALIZING NODE DEPLOYMENT ::"
	@echo "[*] Probing Hardware (Silicon Truth)..."
	@# Determine if we are in Installer Mode (/mnt) or Live Mode (/)
	$(eval ROOT_MNT := $(shell if mountpoint -q /mnt; then echo "/mnt"; else echo "/"; fi))
	
	@# Active Block Detection
	$(eval ROOT_UUID := $(shell findmnt -n -o UUID -T $(ROOT_MNT)))
	$(eval BOOT_UUID := $(shell findmnt -n -o UUID -T $(ROOT_MNT)/boot))
	$(eval SWAP_UUID := $(shell blkid -t TYPE=swap -o value -s UUID | head -n1))
	
	@if [ -z "$(ROOT_UUID)" ] || [ -z "$(BOOT_UUID)" ]; then \
		echo "[!] CRITICAL: Could not detect filesystem UUIDs."; \
		echo "    Root: $(ROOT_UUID)"; \
		echo "    Boot: $(BOOT_UUID)"; \
		exit 1; \
	fi

	@echo "    Target: $(ROOT_MNT)"
	@echo "    Root:   $(ROOT_UUID)"
	@echo "    Boot:   $(BOOT_UUID)"
	@echo "    Swap:   $(SWAP_UUID)"
	@echo ""
	
	@echo "[*] Injecting Identity into hardware.nix..."
	@# Inject Root and Boot
	@sed -i "s|@ROOT_UUID@|$(ROOT_UUID)|g" $(TGT_HW)
	@sed -i "s|@BOOT_UUID@|$(BOOT_UUID)|g" $(TGT_HW)
	
	@# Conditional Swap Injection (Prevents Emergency Mode if swap is missing)
	@if [ -n "$(SWAP_UUID)" ]; then \
		echo "    -> Swap detected. Injecting config."; \
		sed -i "s|@SWAP_CONFIG@|{ device = \"/dev/disk/by-uuid/$(SWAP_UUID)\"; }|g" $(TGT_HW); \
	else \
		echo "    -> No active swap. Clearing config."; \
		sed -i "s|@SWAP_CONFIG@||g" $(TGT_HW); \
	fi
	
	@git add -f "$(TGT_HW)"
	
	@echo "[*] Building System..."
	@# If in installer, install. If live, switch.
	@if [ "$(ROOT_MNT)" = "/mnt" ]; then \
		echo "    Mode: Installer"; \
		sudo nixos-install --root /mnt --flake $(FLAKE) --no-root-passwd; \
	else \
		echo "    Mode: Live Upgrade"; \
		sudo nixos-rebuild switch --flake $(FLAKE) --impure; \
	fi
	@echo ""
	@echo ":: DEPLOY COMPLETE ::"
	@echo ":: REBOOT RECOMMENDED ::"

# 3. MAINTENANCE
sync: fix-windows
	@./bin/macpronix sync

upgrade: fix-windows
	@./bin/macpronix upgrade

status: fix-windows
	@./bin/macpronix status

# 4. HYGIENE
fix-windows:
	@chmod +x bin/macpronix 2>/dev/null || true
	@find . -type f -name "*.nix" -exec sed -i 's/\r$$//' {} + 2>/dev/null || true
	@sed -i 's/\r$$//' Makefile 2>/dev/null || true

validate:
	@nix flake check --show-trace

check: fix-windows
	@test -f VERSION.txt || (echo "[!] Missing VERSION.txt" && exit 1)
	@nix flake check --show-trace