#!/bin/sh

current_dir=${1}
composit_name=${3}-${4}x${5}-${6}s
results_dir=${current_dir}/results/${composit_name}

engine_bin=${current_dir}/${2} # link to executable
tmp_dir=/tmp/vd-engine-${composit_name} # temporary dir for results

mkdir -p $results_dir
cp ${current_dir}/configs/* ${results_dir}/

mkdir -p $tmp_dir
$engine_bin ${tmp_dir}/${3} $4 $5 $6 $7 $8 > ${tmp_dir}/log

mv ${tmp_dir}/* ${results_dir}/
rm -rf ${tmp_dir}
cd ${results_dir}
${current_dir}/slices_graphics_renderer.rb ${composit_name}.sls
cd -

rm -f ${current_dir}/${2} # removing symbolic link to executable
