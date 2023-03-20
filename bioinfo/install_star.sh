

function __install_star () {
  mkdir -p ~/.local/bin;
  builtin cd ~/.local/bin;
  wget https://github.com/alexdobin/STAR/releases/download/2.7.10a_alpha_220207/STAR_Linux_x86_64_static.zip;
  unzip STAR_Linux_x86_64_static.zip;
  rm STAR_Linux_x86_64_static.zip;
  builtin cd ~;
  return 0;
}

