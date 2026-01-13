# ------------------------------------------------------------
# TetraMAX ATPG Script for b14 Design (Partial Scan Mode)
# ------------------------------------------------------------

# Step 1: Read the SAED32 standard-cell Verilog library
read_netlist /cae/apps/data/saed32_edk-2023/lib/stdcell_lvt/verilog/saed32nm_lvt.v

# Step 2: Read the synthesized p-scan netlist
read_netlist results/b14_pscan.vg

# Step 3: Build the ATPG model for the top-level module "b14"
run_build_model b14

# Step 4: Set the STIL file and run DRC (Design Rule Check)
set_drc results/b14_pscan.stil
run_drc

# Step 5: Add all single stuck-at faults for ATPG
add_faults -all

# Step 6: Increase effort to compact/merge patterns (helps reduce pattern count)
set_atpg -merge high

# Step 7: Set abort limit
set_atpg -abort_limit 350

# Step 8: Set a desired coverage goal (as a stopping condition)
set_atpg -coverage 75

# Step 9: add "Fault Coverage" reporting
set_faults -fault_coverage

# Step 10: Run ATPG with automatic test compression
run_atpg -auto_compression

# Step 11: Delete any existing output pattern file to avoid overwrite issues
system "rm -f b14_pattern_pscan.v"

# Step 12: Write the final patterns in binary format for internal scan use
write_patterns b14_pattern_pscan.v -internal -format binary
