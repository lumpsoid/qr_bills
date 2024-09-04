{
  description = "flutter development";

  inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/875233a798e10776166829aacc44ab071780d231"; # breaking flutter update, nixpkgs is pinned for now
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.devshell.follows = "devshell";
    };
    
  };

  outputs = { self, nixpkgs, flake-utils, android-nixpkgs, ... }:
  flake-utils.lib.eachDefaultSystem (system: 
  let
    pkgs = import nixpkgs {
      inherit system;
      config = {
        android_sdk.accept_license = true;
        allowUnfree = true;
      };
    };
    # Everything to make Flutter happy
    sdk = android-nixpkgs.sdk.${system} (sdkPkgs:
      with sdkPkgs; [
        cmdline-tools-latest
        build-tools-30-0-3
        build-tools-34-0-0
        platform-tools
        emulator
        #patcher-v4
        platforms-android-34
      ]);
    pinnedJDK = pkgs.jdk17;
    pinnedFlutter = pkgs.flutter;
  in 
  {
    # don't need to write the <system> part
    # because we inherited system in pkgs
    devShells = {
      default = pkgs.mkShell {
        name = "qr-bills-devshell";

        buildInputs = [
          # Android
          pinnedJDK
          sdk

          # Flutter
          pinnedFlutter

          # Code hygiene
          pkgs.gitlint
        ];

        # android specific envs
        ANDROID_HOME = "${sdk}/share/android-sdk";
        ANDROID_SDK_ROOT = "${sdk}/share/android-sdk";
        JAVA_HOME = pinnedJDK;

        GRADLE_USER_HOME = "/home/qq/.gradle";
      };
    };
  });
}
