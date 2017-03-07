{ reflex-platform ? import ./reflex-platform {}
, androidPackagePrefix ? "systems.obsidian"
, appName ? "app"
}:

rec {
  inherit (reflex-platform) nixpkgs;
  inherit (nixpkgs) lib androidenv;
  androidNdk = androidenv.androidndk;
  appSrc = ./hs;

  platforms = {
    "arm64-v8a" = {
      nixpkgsAndroid = reflex-platform.nixpkgsCross.android.arm64Impure;
      androidHaskellPackagesBase = reflex-platform.ghcAndroidArm64;
    };
    "armeabi-v7a" = {
      nixpkgsAndroid = reflex-platform.nixpkgsCross.android.armv7aImpure;
      androidHaskellPackagesBase = reflex-platform.ghcAndroidArmv7a;
    };
  };

  abiVersions = lib.concatStringsSep " " (lib.attrNames platforms);

  cabalFile = nixpkgs.runCommand "${appName}.cabal" {} ''
    cat > "$out" <<EOF
    name: appName
    version: 0.1.0.0
    -- synopsis:
    -- description:
    license: MIT
    -- license-file: LICENSE
    -- author:
    -- maintainer:
    -- copyright:
    -- category:
    build-type: Simple
    cabal-version: >=1.8

    executable lib${appName}.so
      build-depends: base
                   , jsaddle
                   , jsaddle-clib
                   , reflex
                   , reflex-dom-core
                   , transformers
      hs-source-dirs: src
      ghc-options: -Rghc-timing -shared -fPIC -threaded -no-hs-main -lHSrts_thr -lCffi -lm -llog
      main-is: App.hs
      c-sources: cbits/focus.c
      include-dirs: cbits/include
      includes: jni.h
      install-includes: cbits/include/focus.h
      exposed-modules: App
      cc-options: -shared -fPIC
      ld-options: -shared
    EOF
  '';

  appSOs = lib.mapAttrs (abiVersion: { nixpkgsAndroid, androidHaskellPackagesBase }: rec {
    inherit (nixpkgsAndroid.buildPackages) patchelf;
    inherit (nixpkgsAndroid) libiconv;
    androidHaskellPackages = androidHaskellPackagesBase.override {
      overrides = self: super: {
        mkDerivation = drv: super.mkDerivation (drv // {
          dontStrip = true;
          enableSharedExecutables = false;
          configureFlags = (drv.configureFlags or []) ++ [
            "--ghc-option=-fPIC"
            "--ghc-option=-optc-fPIC"
            "--ghc-option=-optc-shared"
            "--ghc-option=-optl-shared"
          ];
        });
      };
    };
    hsApp = androidHaskellPackages.callPackage ({ mkDerivation, jsaddle, jsaddle-clib, reflex, reflex-dom-core }:
      mkDerivation (rec {
        pname = "app";
        version = "0";
        license = null;
        src = nixpkgs.runCommand "app-src" {
          buildCommand = ''
            mkdir "$out"
            cp -r --no-preserve=mode "${appSrc}"/* "$out"/
          '';
        } "";
        buildDepends = [ jsaddle jsaddle-clib reflex reflex-dom-core ];
        buildTools = [ ];
        isExecutable = false;
        isLibrary = false;
        passthru = {
          inherit cabalFile;
          haskellPackages = androidHaskellPackages;
        };
        doHaddock = false;
        preConfigure = ''
          ln -s "${cabalFile}" "app.cabal"
        '';
        postFixup = ''
          SOPATH=$(echo $out/bin/*.so)
          patchelf --remove-rpath $SOPATH
        '';
    })) {};
  }) platforms;

  androidSrc = import ./android {
    inherit nixpkgs;
    name = appName;
    inherit appSOs;
    packagePrefix = androidPackagePrefix;
    assets = ./android/assets;
    res    = ./android/res;
  };

  androidApp = nixpkgs.androidenv.buildApp {
    name = appName;
    src = androidSrc;
    platformVersions = [ "21" ];
    useGoogleAPIs = true;
    inherit abiVersions;
    useNDK = true;
    release = true;
    keyStore = ./keystore;
    keyAlias = "focus";
    keyStorePassword = "password";
    keyAliasPassword = "password";
  };

  androidEmulate = nixpkgs.androidenv.emulateApp {
    name = appName;
    app = androidApp;
    platformVersion = "21";
    useGoogleAPIs = true;
    inherit abiVersions;
    enableGPU = true;
    package = androidPackagePrefix + "." + appName;
    activity = ".MainActivity";
  };
}
