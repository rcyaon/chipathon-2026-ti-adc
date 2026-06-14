# Folder Structure 
```
analog/
├── blocks/
│   ├── cell/ 
│   │   ├── cell.sch
│   │   ├── cell.gds
│   │   └── sim/
│   │       ├── tb_cell.sch
│   │       └── tb_cell.spice
|   └── another_cell/
│       ├── another_cell.sch
│       ├── another_cell.gds
│       └── sim/
│           ├── tb_another_cell.sch
│           └── tb_another_cell.spice
├── top/
│   └── top.gds
│   └── top.lef
|   └── sim/
│       └── tb_top.sch
│       └── tb_top.spice
└── README.md
````

## blocks/
Individual circuit blocks, each self-contained with schematic, layout, and simulation testbench.

## top/
Full assembled design connecting all blocks, with final GDS and LEF for handoff.

# Committing Guidelines

## Format
`type(scope): short description`

## Types
- `feat` — new circuit block, schematic, or layout
- `fix` — DRC fix, LVS fix, simulation error
- `sim` — new or updated testbench
- `docs` — README, comments, documentation
- `chore` — cleanup, file moves, config

## Scopes
- `cell` — [describe cell]
- `top` — top-level assembly
- `sim` — simulations
- `docs` — documentation
