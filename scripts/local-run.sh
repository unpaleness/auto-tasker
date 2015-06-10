#!/bin/sh

current_dir=$(pwd)
results_dir=${current_dir}/results
result_name=${3}-${4}x${5}-${6}s
engine_bin=${current_dir}/${1} # link to executable

mkdir -p ${results_dir}
cp ${current_dir}/configs/* ${results_dir}/

$engine_bin ${results_dir}/${2} $3 $4 $5 $6 $7 > ${results_dir}/log

cd ${results_dir}
${current_dir}/slices_graphics_renderer.rb ${result_name}.sls
cd -

rm -f ${engine_bin} # removing symbolic link to executable
