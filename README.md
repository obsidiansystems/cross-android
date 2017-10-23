## This repository is deprecated


### Old README

Build all the way to android:

nix-build -A androidApp

Build only the haskell bit:

nix-build -A hsApp

Get a shell with cross binutils:

nix-shell -E 'let rp = (import ./reflex-platform {}).nixpkgsCross.android.arm64; in rp.stdenv.mkDerivation { name = "shell"; buildInput = [ rp.buildPackages.binutilsCross ]; }'

Get a shell with cross ghc:

nix-shell -E 'let rp = (import ./reflex-platform {}).ghcAndroidArm64; in rp.stdenv.mkDerivation { name = "shell"; buildInput = [ rp.ghc ]; }'
