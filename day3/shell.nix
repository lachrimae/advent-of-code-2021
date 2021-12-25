let nixpkgs = import <nixpkgs> {};
in
with nixpkgs;
mkShell {
  buildInputs = [
    gcc
    gdb
    nasm
    python3
  ];
}
