{ name
, packagePrefix ? "systems.obsidian"
, nixpkgs
, ghc
, app
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

    cp -r --no-preserve=mode "$src/res" $out

    cp -r --no-preserve=mode "$src/jni" $out
    # sed -i 's|systems_obsidian_focus|'"${packageJNIName}"'|' "$out/jni/"*"."{c,h}

    #GHCLIBPATH=$ghc/lib/$(stripHash $ghc)
    #LIBHSBASEPATH=$(echo $GHCLIBPATH/base-*/libHSbase-*-ghc*.so)
    #LIBHSBASENAME=$(basename $LIBHSBASEPATH)
    #cp --no-preserve=mode $LIBHSBASEPATH $out/jni/$LIBHSBASENAME
    #
    #LIBHSINTEGERPATH=$(echo $GHCLIBPATH/integer-simple-*/libHSinteger-simple-*-ghc*.so)
    #LIBHSINTEGERNAME=$(basename $LIBHSINTEGERPATH)
    #cp --no-preserve=mode $LIBHSINTEGERPATH $out/jni/$LIBHSINTEGERNAME
    #
    #LIBHSPRIMPATH=$(echo $GHCLIBPATH/ghc-prim-*/libHSghc-prim-*-ghc*.so)
    #LIBHSPRIMNAME=$(basename $LIBHSPRIMPATH)
    #cp --no-preserve=mode $LIBHSPRIMPATH $out/jni/$LIBHSPRIMNAME
    #
    #LIBHSRTSPATH=$(echo $GHCLIBPATH/rts/libHSrts_thr-ghc*.so)
    #LIBHSRTSNAME=$(basename $LIBHSRTSPATH)
    #cp --no-preserve=mode $LIBHSRTSPATH $out/jni/$LIBHSRTSNAME
    #
    #LIBHSFFIPATH=$(echo $GHCLIBPATH/rts/libffi.so)
    #LIBHSFFINAME=$(basename $LIBHSFFIPATH)
    #cp --no-preserve=mode $LIBHSFFIPATH $out/jni/$LIBHSFFINAME
    #
    #
    #for CURLIB in "$LIBHSBASENAME" "$LIBHSINTEGERNAME" "$LIBHSPRIMNAME" "$LIBHSRTSNAME" "$LIBHSFFINAME"
    #do
    #  patchelf --remove-needed libffi.so.6 $out/jni/$CURLIB
    #  patchelf --remove-needed libm.so.6 $out/jni/$CURLIB
    #  patchelf --remove-needed librt.so.1 $out/jni/$CURLIB
    #  patchelf --remove-needed libdl.so.2 $out/jni/$CURLIB
    #  patchelf --remove-needed libpthread.so.0 $out/jni/$CURLIB
    #  patchelf --remove-needed libc.so.6 $out/jni/$CURLIB
    #done
    #
    # point to HS application shared object
    #APPLIBPATH=$(echo "${app}"/bin/*.so)
    #APPLIBNAME=$(basename $APPLIBPATH)
    #cp --no-preserve=mode $APPLIBPATH $out/jni/$APPLIBNAME
    #
    #substituteInPlace $out/jni/Android.mk \
    #  --subst-var LIBHSBASENAME \
    #  --subst-var LIBHSINTEGERNAME \
    #  --subst-var LIBHSPRIMNAME \
    #  --subst-var LIBHSRTSNAME \
    #  --subst-var LIBHSFFINAME \
    #  --subst-var APPLIBNAME
  '';
}
