---
series: Hello World App
title: Cross-Platform C++ Dev Setup on macOS Sierra
hero: hello-world-app
image-credit: Toni Rodrigo
image-credit-link: https://www.flickr.com/photos/tonirodrigo/2482188903/
date: September 14, 2017
redirect_from:
  - /cross-platform-cplusplus-dev-setup-on-os-x-yosemite/
---

In this tutorial we will set up your local environment for developing cross-platform C++ apps on macOS Sierra (version 10.12.6 at the time of writing). There are several lengthy downloads, so grab some coffee/beer/snacks.

Not all tutorials will require all of these downloads, but ultimately to publish an app including C++ code on both iOS and Android devices/simulators you will need all of the software listed below.

## 1. Xcode

| Link | Size |
|:--|:--|
| [Xcode on the Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835) | 4.54 GB |

Needed to publish iOS apps to a simulator or device. You will need a paid developer account to publish to a device.

After installing, open up Xcode for the first time and agree to the license agreement and install additional components. After Xcode finishes installing the components, you can exit Xcode for now.

## 2. Xcode Command Line Tools

In the Terminal app type:

`xcode-select --install`

Allows us to build Xcode project files from the command line. After entering the command above, click the 'Install' button. You will then be prompted to agree to another license agreement.

## 3. Java Development Kit (JDK)

| Link | Size |
|:--|:--|
| [Java Development Kit (JDK) Download Page](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) | 227 MB |

We will need the Java JDK in order to run Android Studio and publish to Android devices and simulators. After downloading, verify that the JDK was installed correctly by running the following command in the Terminal app:

`java -version`

You should see a response like the following:

```
java version "1.8.0_65"
Java(TM) SE Runtime Environment (build 1.8.0_65-b17)
Java HotSpot(TM) 64-Bit Server VM (build 25.65-b01, mixed mode)
```

## 4. Android Studio SDK

| Link | Size |
|:--|:--|
| [Android Studio Download Page](https://developer.android.com/sdk/index.html) | 227 MB |
| Additional SDK Packages | 715 MB |

Needed to publish Android apps to either a simulator or device.

After downloading, open up Android Studio and follow the prompts for a Custom Install Type. Pick either the light or dark theme, and check all boxes on the SDK Components Setup:

![SDK Components Setup](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/environment-setup/sdk_components_setup.png "SDK Components Setup")

## 5. Android NDK

| Link | Size |
|:--|:--|
| [Android NDK Download Page](http://developer.android.com/ndk/downloads/index.html) | 371 MB |

Needed for GYP to generate Android studio files and for Android Studio to understand C++ code.

We can actually install the NDK from within Android Studio in the Project Structure section.

From the quick start menu select **Configure > Project Defaults > Project Structure**, or from the main nav select **File > Other Settings > Default Project Structure**.

This should take you to a screen showing the location of the Android SDK and the JDK we installed earlier in this tutorial. Currently, the Android NDK location should be blank:

![NDK Install](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/environment-setup/ndk_install.png "NDK Install")

Click the 'Download Android NDK' link below the text field, which will start the NDK download. After the download and install completes, you should be able to return to this screen and see the NDK location filled in.

Our last step is to set up our $PATH as well as some Android variables in our bash profile.

Add the following to the .bash_profile file in your $HOME directory. You may need to create the file if you do not have one:

**$HOME/.bash_profile:**

```
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

export ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk-bundle
export PATH=$PATH:$ANDROID_NDK_HOME
```

Then, be sure to reload your bash profile with the following command in the Terminal app:

`source ~/.bash_profile`

To verify that the SDK and NDK command line tools were installed properly for use with GYP, run the following commands in the Terminal app and verify you see a similar output (except with your home directory):


`which android`

```
/Users/stephenspann/Library/Android/sdk/tools/android
```

`which ndk-build`

```
/Users/stephenspann/Library/Android/sdk/ndk-bundle/ndk-build
```

If you've made it this far, then you should be set to tackle the other tutorials on this site. Hopefully we've installed everything you need to get started, and you won't be delayed during any of the other tutorials.

If you run into an issue, feel free to submit an issue or (preferably) a pull request on [GitHub](https://github.com/spanndemic/mobilecpptutorials)