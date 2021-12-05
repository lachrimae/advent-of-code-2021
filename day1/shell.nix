let nixpkgs = import <nixpkgs> {};
in
with nixpkgs;
mkShell {
  buildInputs = [
    gcc
    sqlite
    coreutils
  ];
}
