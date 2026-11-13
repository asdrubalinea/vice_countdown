{ pkgs, ... }:

{
  languages.gleam.enable = true;
  # lustre_dev_tools runs on the Erlang target; the app itself compiles to JS
  languages.erlang.enable = true;
  packages = [ pkgs.rebar3 ];

  scripts.dev.exec = "gleam run -m lustre/dev start";
  scripts.build.exec = "gleam run -m lustre/dev build --minify";
}
