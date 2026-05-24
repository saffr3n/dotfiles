{ config, pkgs, ... }: {
  home.packages = [ pkgs.lazygit ];

  programs.bash.bashrcExtra = ''
    function lg() {
      export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
      command lazygit "$@"
      if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
        cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
        rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
      fi
    }
  '';

  xdg.configFile.lazygit = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/lazygit";
    recursive = true;
  };
}
