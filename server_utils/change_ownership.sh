#!/usr/bin/env bash

\builtin set -o errexit;    # abort on nonzero exitstatus
\builtin set -o nounset;    # abort on unbound variable
\builtin set -o pipefail;   # don't hide errors within pipes

# Change ownership of directories recursively based on who owns it
function change_ownership () {
  \builtin local current_owner;
  \builtin local current_owner_temp;
  \builtin local new_owner;
  # \builtin local dir_arr;
  
  current_owner="${1:-}";
  new_owner="${2:-}";
  
  # dir_arr="${@:3}";

  \builtin echo -ne "${*:3}\n";

  for dir_path in "${@:3}"; do
    current_owner_temp="$(\stat -c '%U' "${dir_path}")";
    \builtin echo -ne "${dir_path}\n";
    if [[ "${current_owner_temp}" == "${current_owner}" ]]; then
      \chown -R "${new_owner}" "${dir_path}";
    fi
  done
  \builtin return 0;
}

change_ownership "${@}";

\builtin exit 0;
