#!/usr/bin/env python3
"""Generate DBML from solardev_attributes.csv and solardev_relationships.csv."""
import csv
from pathlib import Path
SCHEMA_DIR = Path(__file__).resolve().parent
OUTPUT_DBML = SCHEMA_DIR / "solardev_schema.dbml

def main():
    OUTPUT_DBML.write_text("// Generated", encoding="utf-8")
    print(f"Wrote {OUTPUT_DBML}")
if __name__ == "__main__":
    main()
