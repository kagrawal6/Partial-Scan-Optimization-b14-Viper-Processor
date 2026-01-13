# Partial-Scan-Optimization-b14-Viper-Processor

1. To use synthesis_pscan.tcl:


a. Run design vision in /filespace/k/kagrawal24/ece553/do_synth

cd /filespace/k/kagrawal24/ece553/do_synth
/cae/apps/bin/design_vision


b. In design_vison, to run the script type

source synthesis_pscan.tcl



2. To use tmax_pscan.tcl


a. After you are done running the synthesis_pscan.tcl script, you need to run tmax in /filespace/k/kagrawal24/ece553/do_synth

cd /filespace/k/kagrawal24/ece553/do_synth
/cae/apps/bin/oldver/tmax 


b. In tmax, to run the script type

source tmax_pscan.tcl



This will generate the required Uncollapsed Stuck Fault Summary Report and Pattern Summary Report on tmax alongside the binary test pattern file 
b14_pattern_pscan.v. 