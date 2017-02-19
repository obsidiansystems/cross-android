let reflex-platform = import ./reflex-platform {};
    inherit (reflex-platform) nixpkgs;
    androidPackagePrefix = "systems.obsidian";
    appName = "app";
in rec {
  inherit (nixpkgs) androidenv;
  vim = nixpkgs.vim;
  patchelf = reflex-platform.nixpkgsCross.android.arm64Impure.buildPackages.patchelf;
  libiconv = reflex-platform.nixpkgsCross.android.arm64Impure.libiconv;
  androidHaskellPackagesBase = reflex-platform.ghcAndroidArm64;
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
  androidNdk = androidenv.androidndk;
  appSrc = ./hs;
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
      hs-source-dirs: src
      ghc-options: -shared -fPIC -threaded -no-hs-main -lHSrts -lCffi -lm -llog
      main-is: App.hs
      c-sources: cbits/focus.c
      include-dirs: cbits/include, "${androidNdk}/libexec/android-ndk-r10e/platforms/android-21/arch-arm64/usr/include/"
      includes: jni.h
      install-includes: cbits/include/focus.h
      exposed-modules: App
      cc-options: -shared -fPIC
      ld-options: -shared
    EOF
  '';
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
  androidSrc = import ./android {
    inherit nixpkgs libiconv;
    inherit (androidHaskellPackages) ghc;
    name = appName;
    app = hsApp;
    packagePrefix = androidPackagePrefix;
  };
  androidApp = nixpkgs.androidenv.buildApp {
    name = appName;
    src = androidSrc;
    platformVersions = [ "21" ];
    useGoogleAPIs = true;
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
    enableGPU = true;
    abiVersion = "arm64-v8a";
    useGoogleAPIs = true;
    package = androidPackagePrefix + "." + appName;
    activity = ".MainActivity";
  };
}

/*
*/
