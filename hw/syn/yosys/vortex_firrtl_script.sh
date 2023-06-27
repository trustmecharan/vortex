#!/bin/bash

#!this script uses sv2v and yosys tools to run.
# sv2v: https://github.com/zachjs/sv2v
# yosys: http://www.clifford.at/yosys/

# exit when any command fails
set -e

source=""
top_level=""
dir_list=()
inc_args=""
macro_args=""

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts "s:t:I:D:h" arg; do
    case $arg in
    s) # source
        source=${OPTARG}
        ;;
    t) # top-level
        top_level=${OPTARG}
        ;;
    I) # include directory
        dir_list+=(${OPTARG})
        inc_args="$inc_args -I${OPTARG}"
        ;;
    D) # macro definition
        macro_args="$macro_args -D${OPTARG}"
        ;;
    h | *) 
      usage
      exit 0
      ;;
  esac
done

{    
    # START OF VORTEX
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/fp_cores"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/interfaces"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/libs"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/cache"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/tex_unit"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/afu"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/fpnew/src/fpu_div_sqrt_mvp/hdl"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/fpnew/src/common_cells/include"
    echo "read -incdir /mnt/c/Users/Charan/Documents/RA/vortex/hw/fpnew/src/common_cells/test"

    # read design sources
    for dir in "/mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/interfaces" 
    do
        for file in $(find $dir -name '*.sv' -o -name '*.vh') 
        do
            echo "read -sv $macro_args $inc_args $file"
        done
    done

    for dir in "/mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/libs" 
    do
        for file in $(find $dir -name '*.sv' -o -name '*.vh') 
        do
            echo "read -sv $macro_args $inc_args $file"
        done
    done

    for dir in "/mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/cache" 
    do
        for file in $(find $dir -name '*.sv' -o -name '*.vh') 
        do
            echo "read -sv $macro_args $inc_args $file"
        done
    done

    for file in /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/*.vh; 
    do
        echo "read -sv $macro_args $inc_args $file"
    done

    for file in /mnt/c/Users/Charan/Documents/RA/vortex/hw/dpi/*.vh; 
    do
        echo "read -sv $macro_args $inc_args $file"
    done

    for file in /mnt/c/Users/Charan/Documents/RA/vortex/hw/rtl/*.sv; 
    do
        echo "read -sv $macro_args $inc_args $file"
    done

    if [ -n "$source" ]; then
        echo "read -sv $macro_args $inc_args $source"
    fi

    # generic synthesis
    echo "prep -flatten -top Vortex"
    # echo "hierarchy -auto-top" # NEW
    # echo "setattr -set keep 1" # NEW
    # echo "proc;" # NEW
    # echo "scc -all_cell_types"
    # echo "scc"
    echo "async2sync" # NEW

    echo "memory"
    # echo "memory_map"
    # echo "proc; opt;"

    # mapping to mycells.lib
    # echo "synth"
    # echo "dfflibmap -liberty mycells.lib"
    # echo "techmap" # new
    # echo "abc -liberty mycells.lib"
    # echo "clean"

    # write synthesized design
    # echo "write_verilog vortex.v"
    # echo "write_rtlil vortex.il"

    echo "write_firrtl Vortex.fir"

} > synth.ys

yosys -l yosys.log synth.ys