{ config, pkgs, ... }: {
  home.packages = [ pkgs.yazi ];

  programs.bash.bashrcExtra = ''
    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      command yazi "$@" --cwd-file="$tmp"
      if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';

  xdg.configFile.yazi = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/yazi";
    recursive = true;
  };
}
