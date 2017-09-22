---
series: Hello World App
title: Cross-Platform C++ Dev Setup on macOS Sierra
hero: dev-setup
image-credit: Travis Wise
image-credit-link: https://www.flickr.com/photos/photographingtravis/16212948441/
redirect_from:
  - /cross-platform-cplusplus-dev-setup-on-os-x-yosemite/
---

In this tutorial we will set up your local environment for developing cross-platform C++ apps on macOS Sierra (version 10.12.6 at the time of writing). There are several lengthy downloads, so grab some coffee/beer/snacks.

Not all tutorials will require all of these downloads, but ultimately to publish an app including C++ code on both iOS and Android devices/simulators you will need all of the software listed below.

## 1. Xcode

| Link | Size |
|:--|:--|
| [Xcode on the Mac App Store](https://itunes.apple.com/us/app/xcode/id497799835) | 4.54 GB |

Xcode is needed to publish iOS apps to a simulator or device. You will be able to publish to a simulator for free, but in order to publish to a device you will need a paid developer account.

After installing, open up Xcode for the first time and agree to the license agreement. Xcode will then install additional components we will need (like Git).

## 2. Java Development Kit (JDK)

| Link | Size |
|:--|:--|
| [Java Development Kit (JDK) Download Page](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) | 227 MB |

We will need the Java JDK in order to run Djinni and Android Studio. On the page above, agree to the license agreement then download the version for 'Mac OS X'.

After downloading, verify that the JDK was installed correctly by running the following command in the Terminal app:

`java -version`

You should see a response like the following:

```
java version "1.8.0_144"
Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
```

## 3. Android Studio SDK

| Link | Size |
|:--|:--|
| [Android Studio Download Page](https://developer.android.com/sdk/index.html) | 227 MB |
| Additional SDK Packages | 715 MB |

Needed to publish Android apps to either a simulator or device.

After downloading, open up Android Studio and follow the prompts for a Custom Install Type. Pick either the light or dark theme, and check all boxes on the SDK Components Setup so we have a Virtual Device to run our Android apps on:

![SDK Components Setup]({{ "/assets/images/environment-setup/sdk_components_setup.png" | prepend:site.baseurl }} "SDK Components Setup")

After clicking 'OK' get another coffee/beer/snack because you'll be on the 'Downloading Components' screen a while.

## 4. Android NDK and CMake

We need to install both the Android NDK (Native Development Kit) and CMake to publish an Android app with C++ code.

We can actually install the NDK from within Android Studio in the Project Structure section.

From the quick start menu select **Configure > SDK Manager** from the dropdown at the bottom:

![Configure SDK Manager]({{ "/assets/images/environment-setup/configure_sdk_manager.png" | prepend:site.baseurl }} "Configure SDK Manager")

On the screen that follows, click **SDK Tools** at the top, and be sure you have all of the following checked and installed - CMake, Android Emulator, and the NDK:

![Android SDK Manager]({{ "/assets/images/environment-setup/android_sdk_manager.png" | prepend:site.baseurl }} "Android SDK Manager")

Click the 'OK' button to accept more license agreements and begin the downloads. 

If you've made it this far, then you should be set to tackle the other tutorials on this site. Hopefully we've installed everything you need to get started, and you won't be delayed during any of the other tutorials.

If you run into an issue, feel free to submit an issue or (better yet!) a pull request on [GitHub](https://github.com/spanndemic/mobilecpptutorials)