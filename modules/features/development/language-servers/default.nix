# language-servers Nix flake
#
#  standalone collection of Language Server Protocol (LSP) binaries
#
# provides:
#   - user: clangd, dockerfile-ls, nil, harper, lua-ls, basedpyright, python3, ruff, nixd, ts_ls, vscode-langservers-extracted
#
# required artifacts:
#   - (none)

{ self, ... }:
{
  flake.homeModules.language-servers =
    { pkgs, ... }:
    {
      imports = [ self.homeModules.common ];
      home.packages = with pkgs; [
        clang-tools # clangd
        dockerfile-language-server
        nil
        harper # spellcheck
        lua-language-server
        basedpyright # Enhanced Python type checker & LSP
        python3 # Required by basedpyright for stdlib and environment type analysis
        ruff # Fast Python linter & code formatter
        nixd
        typescript-language-server # ts_ls
        vscode-langservers-extracted # html, eslint
      ];
    };
}
