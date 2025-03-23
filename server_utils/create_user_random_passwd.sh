#!/usr/bin/env bash

# define usernames in array
user_list_var=(testuser01 testuser02 testuser03 testuser04)

# From Iza's CV Bioinfo 2025
# user_list_var=(aluno1 aluno2 aluno3 aluno4 aluno5 aluno6 aluno7 aluno8 aluno9 aluno10 aluno11 aluno12 aluno13 aluno14 aluno15 aluno16 aluno17 aluno18 aluno19 aluno20 aluno21 aluno22 aluno23 aluno24 aluno25 aluno26 aluno27 aluno28 aluno29 aluno30 aluno31 aluno32 aluno33 aluno34 aluno35 aluno36 aluno37 aluno38 aluno39 aluno40 aluno41 aluno42 aluno43 aluno44 aluno45 aluno46 aluno47 aluno48 aluno49 aluno50 aluno51 aluno52 aluno53 aluno54 aluno55 aluno56 aluno57 aluno58 aluno59 aluno60 aluno61 aluno62 aluno63 aluno64 aluno65 aluno66 aluno67 aluno68 aluno69 aluno70)

# Loop to create users
# NOTE: Dependes on `gopass` and `openssl` on the host machine
# NOTE: use sudo if needed
for i in "${user_list_var[@]}"; do
  user_name="${i}";
  user_pw_str="$(\gopass pwgen --one-per-line --ambiguous 24 | head -1)";
  \sudo useradd -m -s /bin/bash -d "/home/${user_name}" -p "$(\openssl passwd -6 ${user_pw_str})" --user-group "${user_name}";
  \builtin echo "User: ${user_name} -> Password: ${user_pw_str}";
done

# =============================================================================
# user_list_var=(usertest01 usertest02 usertest03 usertest04)

# loop to remove users

## To remove te same users run
for i in "${user_list_var[@]}"; do
  user_name="${i}";
  \builtin echo "Removing User: ${user_name}";
  # Command to remove user
  \sudo userdel -r "${user_name}";
  # Command to remove group
  \sudo groupdel "${user_name}";
  # Force Remove the home directory
  if [[ -d /home/${user_name} ]]; then
    \sudo rm -rf "/home/${user_name}";
  fi
done