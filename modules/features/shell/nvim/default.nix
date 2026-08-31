# nvim Nix flake
#
#  hyperextensible text editor with full Lua configuration and embedded LSP toolchains
#
# provides:
#   - user: neovim, tree-sitter tools, wl-clipboard, fd, lazygit + imported language-servers + Lua config symlink
#
# required artifacts:
#   - init.lua
#   - nvim-pack-lock.json
#   - assets/logo.txt
#   - spell/en.utf-8.add

{ self, ... }:
{
  flake.homeModules.nvim =
    { link, pkgs, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.language-servers
      ];
      home.packages = with pkgs; [
        neovim
        gcc # nvim-treesitter parser compilation
        luaPackages.tree-sitter-cli
        wl-clipboard # nvim clipboard integration
        fd # Snacks picker & explorer file traversal
        lazygit # Snacks lazygit integration
        sqlite.out # Snacks picker frecency & history shared library
      ];
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      xdg.configFile."nvim".source = link "modules/features/shell/nvim";
      programs.bash.shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };
    };
}
