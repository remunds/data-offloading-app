{ pkgs ? import <nixpkgs> { 
  config.android_sdk.accept_license = true;
  config.allowUnfree = true;
   overlays = [
     (self: super: {
       licenseAccepted = true;
       androidPkgs_10_0 = super.androidenv.composeAndroidPackages {
         platformVersions = [ "29" ];
         abiVersions = [ "x86" "x86_64"];
       };
     })
   ];
},
}:
pkgs.mkShell {
    #buildInputs = with pkgs; [ flutter androidPkgs_10_0.androidsdk jdk ];
    buildInputs = with pkgs; [ flutter androidPkgs_10_0.androidsdk androidenv.androidPkgs_9_0.androidsdk jdk ];
    shellHook=''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.jdk.home}
      export ANDROID_HOME=${pkgs.androidPkgs_10_0.androidsdk}/libexec/android-sdk
      export ANDROID_HOME_OLD=${pkgs.androidenv.androidPkgs_9_0.androidsdk}/libexec/android-sdk
      export ANDROID_SDK_ROOT=$ANDROID_HOME
      export ANDROID_SDK_HOME=~/.android
      export FLUTTER_SDK=${pkgs.flutter.unwrapped}
    '';
      #export ANDROID_HOME=${pkgs.androidenv.androidPkgs_9_0.androidsdk}/libexec/android-sdk
}
