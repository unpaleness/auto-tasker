#!/bin/sh

current_dir=$(pwd)
# composit_name=${3}-${4}x${5}-${6}s
# composit_name=$(basename ${current_dir})-${4}x${5}-${6}s
results_dir=${current_dir}/results

engine_bin=${current_dir}/${1} # link to executable
# tmp_dir=/tmp/${composit_name} # temporary dir for results

mkdir -p ${results_dir}
cp -r ${current_dir}/configs ${results_dir}/

# mkdir -p $tmp_dir
# $engine_bin ${tmp_dir}/${2} $3 $4 $5 $6 $7 > ${tmp_dir}/log
cd ${results_dir}
${engine_bin} $2 $3 $4 $5 $6 $7 > log

# mv ${tmp_dir}/* ${results_dir}/
# rm -rf ${tmp_dir}
# cd ${results_dir}
${current_dir}/slices_graphics_renderer.rb *.sls
cd -

rm -f ${engine_bin} # removing symbolic link to executable
