{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
    buildInputs = with pkgs; [ gleam erlang_27 rebar3 ];
}
