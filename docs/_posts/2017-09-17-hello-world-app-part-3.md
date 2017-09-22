---
series: Hello World App
title: Hello World App Part 3, Android
hero: hello-world-app
image-credit: Toni Rodrigo
image-credit-link: https://www.flickr.com/photos/tonirodrigo/2482188903/
redirect_from:
  - /your-first-cross-platform-djinni-app-part-3-android/
---

In the third and final part of this tutorial, we will setup our Android project to include our JNI bridge and C++ functionality from Part 1, then finally publish to a device/simulator.

## Create a New Android Project

Open up Android Studio, and select ‘Start a new Android Studio project’ from the Quick Start menu on the splash screen, or select **File > New > New Project** from the top navigation.

On the info screen, enter the following, being sure the package name and Project location match the screenshot below:

* 'HelloWorld' for the Application name
* 'mycompany.com' for the Company domain
* Check 'Include C++ support'
* Project location is '<your project directory>/android_project/HelloWorld' (This is important so we can use relative file paths to our C++ and JNI code)

![Android New Project]({{ "/assets/images/hello-world-part-3/android_new_project.png" | prepend:site.baseurl }} "Android New Project")

On the second screen, keep the defaults ('Phone and Tablet' checkbox selected, Minimum SDK API 15):

![Android Target Devices]({{ "/assets/images/hello-world-part-3/android_target_devices.png" | prepend:site.baseurl }} "Android Target Devices")

On the third screen, keep the default 'Empty Activity' selected:

![Android Empty Activity]({{ "/assets/images/hello-world-part-3/android_empty_activity.png" | prepend:site.baseurl }} "Android Empty Activity")

On the fourth screen, keep the default Activity Name 'MainActivity' and Layout Name 'activity_main':

![Android Customize Activity]({{ "/assets/images/hello-world-part-3/android_customize_activity.png" | prepend:site.baseurl }} "Android Customize Activity")

On the fifth screen, select 'C++11' for the C++ Standard, and check both the 'Exceptions Support' and 'Runtime Type Information Support' so we have all of the C++ goodies that Android Studio has to offer:

![Android Customize C++]({{ "/assets/images/hello-world-part-3/android_customize_cpp.png" | prepend:site.baseurl }} "Android Customize C++")

Click 'Finish' to complete the wizard, then publish the app to either a simulator or a device with the 'Play' button near the top of the screen to make sure everything is working. You should see a white screen with 'Hello from C++' displayed, but don’t get too excited yet because we still need to implement our C++ code!

## Add Our C++ files to CMakeLists.txt

Android Studio will crate a library for us via CMake, we just have to configure the `CMakeLists.txt` file to point to all of the needed C++ and JNI files.

In the Project folder nav, double click the `CMakeLists.txt` file to open it. This file has some useful notes about CMake builds in general if you want to look them over. For our project, we will just replace the file with the following:

**android_project/HelloWorld/app/CMakeLists.txt**

```
cmake_minimum_required(VERSION 3.4.1)

file(GLOB helloworld_sources
    ../../../deps/djinni/support-lib/jni/*.cpp
    ../../../generated-src/jni/*.cpp
    ../../../src/cpp/*.cpp
)

add_library(helloworld SHARED ${helloworld_sources})

# include directories for header files
include_directories(
    ../../../deps/djinni/support-lib/
    ../../../deps/djinni/support-lib/jni/
    ../../../generated-src/cpp/
    ../../../generated-src/jni/
    ../../../src/cpp/
)

target_link_libraries(helloworld)
```

Notice we've added a list of all `.cpp` source files throughout our project, including the Djinni support library, the automatically-generated bridge code, and our hand-written source files. The `include_directories` includes the paths to all of our `.hpp` header files needed to build the library.

## Add our Java source to the Gradle Build

Next we need to tell Gradle where to find our Java source files that were generated outside of the project. In the project browser, open the `build.gradle` with '(Module: app)' next to it. Either replace the contents of the file with the below code, or you just add the `sourceSets` section to the existing file:

**android_project/HelloWorld/app/build.gradle**

```
apply plugin: 'com.android.application'

android {
    compileSdkVersion 26
    buildToolsVersion "26.0.1"
    defaultConfig {
        applicationId "com.mycompany.helloworld"
        minSdkVersion 15
        targetSdkVersion 26
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
        externalNativeBuild {
            cmake {
                cppFlags "-std=c++11 -frtti -fexceptions"
            }
        }
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    sourceSets {
        main {
            java {
                srcDirs = [
                        "../../../generated-src/java",
                        "src/main/java"
                ]
            }
        }
    }
    externalNativeBuild {
        cmake {
            path "CMakeLists.txt"
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    compile 'com.android.support:appcompat-v7:26.+'
    compile 'com.android.support.constraint:constraint-layout:1.0.2'
    testCompile 'junit:junit:4.12'
}
```

Gradle will need to sync after editing these file, and afterward you should see a ‘jni’ folder in your project browser, as well as additional files in your java folder:

![Android Studio After Gradle]({{ "/assets/images/hello-world-part-3/browser_after_gradle.png" | prepend:site.baseurl }} "Android Studio After Gradle")

## Build the Android UI

Now we can get to coding and implement our C++ library within the Android app.

Back in Android Studio within our project, let’s edit our MainActivity file. It is likely already open, but if not it is usually located in the project browser at this location:

**app > java > com.mycompany.helloworld**

Either replace the contents of the file with the code below, or add the highlighted lines:

`MainActivity.java`

```
package com.mycompany.helloworld;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private HelloWorld cppApi;

    static {
        System.loadLibrary("helloworld");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        cppApi = HelloWorld.create();
    }

    public void buttonWasPressed(View view) {
        String myString = cppApi.getHelloWorld() + "\n";
        TextView t = (TextView) findViewById(R.id.helloWorldText);
        t.setText(myString + t.getText());
    }
}
```

Then edit the `activity_main.xml` file to include our UI with a button to click and a text field to display our C++ responses:

`activity_main.xml`

```xml
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:paddingRight="20dp"
    android:paddingTop="20dp"
    android:orientation="vertical"
    tools:context=".MainActivity">

    <Button
        android:layout_width="280dp"
        android:layout_height="40dp"
        android:textAllCaps="false"
        android:text="Get Hello World!"
        android:onClick="buttonWasPressed" />

    <TextView android:text="" android:layout_width="wrap_content"
        android:id="@+id/helloWorldText"
        android:layout_height="wrap_content" />

</LinearLayout>
```

Now, when you publish the app, you should see “Hello World!” and a timestamp in the text view every time you press the button, just like the implementation in iOS.

Congratulations on completing the tutorial!

## Next Steps

Continue on to the next tutorial, a Todo app using SQLite:

[http://mobilecpptutorials.com/todo-app-using-djinni-and-sqlite-part-1-cplusplus/](http://mobilecpptutorials.com/todo-app-using-djinni-and-sqlite-part-1-cplusplus/)

Check out the Djinni and MX3 repositories on GitHub:

[https://github.com/dropbox/djinni](https://github.com/dropbox/djinni)

[https://github.com/libmx3/mx3](https://github.com/libmx3/mx3)

Watch the video from CPPCon 2014, where Djinni was announced:

[https://www.youtube.com/watch?v=ZcBtF-JWJhM](https://www.youtube.com/watch?v=ZcBtF-JWJhM)
