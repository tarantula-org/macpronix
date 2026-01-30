# Support Protocols

## 1. The Canon
Before asking for help, consult the **Source of Truth**:
* `hosts/trashcan/default.nix` - The OS definition.
* `bin/macpronix` - The control logic.

## 2. Reporting Anomalies
If the node deviates from the expected state:
1.  Run `macpronix status` and capture the telemetry.
2.  Check system logs: `journalctl -xe`.
3.  Open an issue using the **Bug Report** template.

**Note:** Feature requests must be approved by **@tarantula-org/steering**.