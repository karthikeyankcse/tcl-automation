# OrCAD Capture TCL/TK Automation

A collection of **production-ready TCL/TK automation scripts** for OrCAD Capture schematic design workflows. These tools automate repetitive schematic tasks — developed over 6+ years of hands-on EDA engineering.

---

## 📦 Programs

### Part Management
| Program | Description |
|---|---|
| **Part Create** | Automated schematic symbol/part creation from spec data |
| **Part Compare** | Compares part definitions between two libraries for consistency |
| **Part Update** | Batch updates part properties across a schematic |

### Port & Connectivity
| Program | Description |
|---|---|
| **Off-Page Port Placement** | Automates off-page connector placement for multi-page schematics |
| **Connection Validate** | Validates all net connections across schematic pages |
| **Net Audit** | Audits net names for naming convention compliance |

### Site & Design Compare
| Program | Description |
|---|---|
| **Site Compare** | Compares schematic configurations between two design sites |
| **Design Compare** | Full schematic comparison between two OrCAD project revisions |
| **BOM Extract** | Automated BOM extraction from schematic with structured output |

### Validation & Checks
| Program | Description |
|---|---|
| **ERC Check Wrapper** | Automated ERC (Electrical Rules Check) execution and report parsing |
| **Reference Designator Check** | Validates RefDes numbering sequence and uniqueness |
| **Title Block Update** | Batch title block property update across all schematic pages |

---

## 🚀 Highlights

- **Site Compare** — Compares schematic configurations between engineering sites, flags discrepancies in part values, net names, and connectivity.
- **Off-Page Port Placement** — Automatically places and numbers off-page connectors across multi-page schematics, eliminating manual placement errors.
- **Part Create** — Generates complete schematic symbols with correct pin assignments from component spec sheets.

---

## 🛠️ Requirements

- OrCAD Capture (version 17.2 or higher)
- TCL scripting enabled in OrCAD environment

---

## 📂 Usage

1. Open OrCAD Capture
2. Go to **Tools → TCL Scripts**
3. Load and run the `.tcl` file
4. Or execute from OrCAD command line: `source path/to/script.tcl`

---

## 👤 Author

**Karthikeyan K** — EDA Automation Engineer  
[github.com/karthikeyankcse](https://github.com/karthikeyankcse)
