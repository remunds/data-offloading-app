#{ pkgs ? import ~/nixpkgs { 
{ pkgs ? import <nixpkgs> { 
  config.android_sdk.accept_license = true;
  config.allowUnfree = true;
},
}:
pkgs.mkShell {
    #buildInputs = with pkgs; [ flutter androidenv.androidPkgs_10_0.androidsdk jdk ];
    buildInputs = with pkgs; [ flutter androidenv.androidPkgs_9_0.androidsdk jdk ];
    shellHook=''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.jdk.home}
      export ANDROID_HOME=${pkgs.androidenv.androidPkgs_9_0.androidsdk}/libexec/android-sdk
      export ANDROID_SDK_ROOT=$ANDROID_HOME
      export ANDROID_SDK_HOME=~/.android
      export FLUTTER_SDK=${pkgs.flutter.unwrapped}
    '';
}
