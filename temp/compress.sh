#!/usr/bin/env bash

function compress () {
  local input_path;
  local input_name;
  local output_tarball;
  local output_dir;
  local ext_to_add;
  local arg_num;
  local is_dir;

  local mkdir_bin;
  local tar_bin;

  tar_bin="$(require 'tar')";
  ext_to_add='.tar.gz';
  arg_num="${#}";

  if [[ ${arg_num} -eq 0 ]]; then
    return 1;
  fi
  is_dir='false';
  input_path="${1}";
  input_name="$(basename "${input_path}")";
  if [[ ${arg_num} -gt 1 ]]; then
    output_dir="${!arg_num}";
  else
    output_dir="$(realpath ./)";
  fi

  if [[ ! -d ${output_dir} ]]; then
    mkdir_bin="$(require 'mkdir')";
    "${mkdir_bin}" -p "${output_dir}";
  fi

  if [[ -d ${input_path} ]]; then
    is_dir='true';
  fi

  return 0;

  # TODO(luciorq) Not ready yet, everything after this line is untested.

  output_tarball="${output_dir}/${input_name}${ext_to_add}";


  "${tar_bin}" czf "${output_tarball}" "${input_path}";


  return 0;
}
