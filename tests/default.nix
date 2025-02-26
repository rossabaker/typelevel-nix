{ pkgs, typelevelShell, ... }:

{
  native = pkgs.callPackage ./scala-native { inherit typelevelShell; };
}
