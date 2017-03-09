{ name
, packagePrefix
, nixpkgs
, ghc
, app
, libiconv
, abiVersion
, assets
, res
}:

let inherit (nixpkgs) stdenv;
    appName = name;
    packageName = packagePrefix + "." + name;
    packageSrcDir = "src/" + builtins.replaceStrings ["."] ["/"] packageName;
    packageJNIName = builtins.replaceStrings ["."] ["_"] packageName;
    androidSdk = nixpkgs.androidenv.androidsdk_6_0_extras;
in stdenv.mkDerivation {
  inherit androidSdk ghc; # frontend;
  name = "android-app";
  src = ./src;
  nativeBuildInputs = [ nixpkgs.rsync ];
  builder = nixpkgs.writeText "builder.sh" ''
    source "$stdenv/setup"

    mkdir $out

    # copy build files and do substitutions
    cp $src/project.properties $out

    cp $src/local.properties $out
    substituteInPlace $out/local.properties \
      --subst-var-by SDKDIR "${androidSdk}/libexec"

    cp $src/build.xml $out
    substituteInPlace $out/build.xml \
      --subst-var-by PROJECTNAME "${appName}"

    cp $src/custom_rules.xml $out
    substituteInPlace $out/custom_rules.xml \
      --subst-var-by PROJECTNAME "${appName}"

    cp $src/ant.properties $out

    cp $src/AndroidManifest.xml $out
    substituteInPlace $out/AndroidManifest.xml \
      --subst-var-by PACKAGENAME "${packageName}"

    # copy the template project, and then put the src in the right place
    mkdir -p "$out/${packageSrcDir}"
    cp -r --no-preserve=mode "$src/src/." "$out/${packageSrcDir}"
    sed -i 's|package systems.obsidian.focus;|package '"${packageName}"\;'|' "$out/${packageSrcDir}/"*".java"

    substituteInPlace "$out/${packageSrcDir}/MainActivity.java" \
      --subst-var-by APPNAME "${appName}"

    cp -r --no-preserve=mode "$src/assets" $out

    cp -r --no-preserve=mode "$src/res" $out
    substituteInPlace "$out/res/values/strings.xml" \
      --subst-var-by APPDISPLAYNAME "${appName}"

    cp -r --no-preserve=mode "$src/jni" $out
    substituteInPlace $out/jni/Application.mk \
      --subst-var-by ABI_VER "${abiVersion}"
    # sed -i 's|systems_obsidian_focus|'"${packageJNIName}"'|' "$out/jni/"*"."{c,h}

    # move libiconv to the correct place
    cp --no-preserve=mode "${libiconv}/lib/libiconv.so" $out/jni
    cp --no-preserve=mode "${libiconv}/lib/libcharset.so" $out/jni

    # point to HS application shared object
    APPLIBPATH=$(echo "${app}"/bin/*.so)
    APPLIBNAME=$(basename $APPLIBPATH)
    cp --no-preserve=mode $APPLIBPATH $out/jni/$APPLIBNAME

    substituteInPlace $out/jni/Android.mk \
      --subst-var APPLIBNAME

    rsync -r --chmod=+w "${assets}"/ "$out/assets/"
    rsync -r --chmod=+w "${res}"/ "$out/res/"
    [ -d "$out/assets" ]
    [ -d "$out/res" ]
  '';
}
