{ pkgs, typelevelShell, ... }:

let
  shell = pkgs.devshell.mkShell {
    imports = [ typelevelShell ];
    packages = [ pkgs.which ];
    typelevelShell.native.enable = true;
  };
in pkgs.runCommand "test-scala-native" {} ''
  export PRJ_ROOT=$PWD
  source ${shell}/entrypoint
  export SBT_DEPS=$(mktemp -d)
  export SBT_OPTS="-Dsbt.global.base=$SBT_DEPS/project/.sbtboot -Dsbt.boot.directory=$SBT_DEPS/project/.boot -Dsbt.ivy.home=$SBT_DEPS/project/.ivy $SBT_OPTS"
  export COURSIER_CACHE=$SBT_DEPS/project/.coursier
  mkdir -p $SBT_DEPS/project/{.sbtboot,.boot,.ivy,.coursier}
  cp -r ${./.}/. $SBT_DEPS/
  cd $SBT_DEPS
  sbt run
  touch $out
''
