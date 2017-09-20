---
series: Hello World App
title: Hello World App Part 3, Android
hero: hello-world-app
image-credit: Toni Rodrigo
image-credit-link: https://www.flickr.com/photos/tonirodrigo/2482188903/
redirect_from:
  - /your-first-cross-platform-djinni-app-part-3-android/
---

In the third and final part of this tutorial, we will setup our initial Android project, build a JNI library from our Djinni files, include the library in our Android project and finally publish to a device/simulator.

**January 26, 2016:**
This tutorial was updated to use the experimental Gradle plugin instead of building libraries with GYP.

## Create a New Android Project

Open up Android Studio, and select ‘Start a new Android Studio project’ from the Quick Start menu on the splash screen, or select **File > New > New Project** from the top navigation.

On the info screen, enter the following:

Application Name: Hello World

Company Domain: mycompany.com

Project Location: Create a new folder inside your project, here I’ve chosen ‘android_project’ to be consistent with our other Xcode project naming:

![Android Studio New Project]({{ "/assets/images/hello-world-part-3/AS_new_project.png" | prepend:site.baseurl }} "Android Studio New Project")

*Be sure to set the company domain to ‘mycompany.com’. This is utilized in your java package name which is used in other scripts in this tutorial.*

For the remaining screens in the wizard (Form Factors, Add an Activity, and Customize the Activity), just click ‘Next’ or ‘Finish’ to keep the defaults.

Publish the app to make sure it works, selecting either an Android device connected to your machine or an available simulator. You’ll see “Hello World” in an otherwise blank Android screen when the app runs, but don’t get too excited because we still need to implement our C++ code!

*If this is the first time you are publishing to an Android device, you may need to enable USB debugging on the device (should get a popup on the device).*

## Configure the Experimental Gradle Build

We will utilize the experimental gradle plugin with Android Studio which provides a bit more C++ support when compiling the project (without the need for makefiles or GYP).

More information regarding the setup of the experimental gradle plugin can be found here: http://tools.android.com/tech-docs/new-build-system/gradle-experimental

Edit the following files either by using a text editor or directly in Android Studio under ‘Gradle Scripts’:

`gradle-wrapper.properties`:

```
#Wed Oct 21 11:34:03 PDT 2015
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-2.10-all.zip
```

`HelloWorld/build.gradle`:

```
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath "com.android.tools.build:gradle-experimental:0.8.3"

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        jcenter()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

*The format of the following build.gradle file has been subject to change several times in recent months. If you get errors, double check what version of the plugin you are using, and check the experimental plugin page for syntax updates: [http://tools.android.com/tech-docs/new-build-system/gradle-experimental](http://tools.android.com/tech-docs/new-build-system/gradle-experimental)*


`app/build.gradle`

```
apply plugin: "com.android.model.application"

model {
    android {
        compileSdkVersion 23
        buildToolsVersion "23.0.0"

        defaultConfig.with {
            applicationId "com.mycompany.helloworld"
            minSdkVersion.apiLevel 15
            targetSdkVersion.apiLevel 22
            versionCode 1
            versionName "1.0"
        }

        buildTypes {
            release {
                minifyEnabled false
                proguardFiles.add(file("proguard-rules.pro"))
            }
        }

        productFlavors {
            create("flavor1") {
                applicationId "com.mycompany.helloworld"
            }
        }

        sources {
            main {
                jni {
                    source {
                        srcDirs = [
                                "../../../deps/djinni/support-lib/jni",
                                "../../../generated-src/cpp",
                                "../../../generated-src/jni",
                                "../../../src/cpp"
                        ]
                    }
                }

                java {
                    source {
                        srcDirs = [
                                "../../../generated-src/java",
                                "src/main/java"
                        ]
                    }
                }
            }
        }
        ndk {
            toolchain = "gcc"
            toolchainVersion = "4.9"
            moduleName = "helloworld"
            stl = "gnustl_shared"
            cppFlags.add("-std=c++11")
            cppFlags.add("-fexceptions")
            cppFlags.add("-frtti")
            cppFlags.add("-I${file("../../../deps/djinni/support-lib")}".toString())
            cppFlags.add("-I${file("../../../deps/djinni/support-lib/jni")}".toString())        // djinni src
            cppFlags.add("-I${file("../../../generated-src/cpp")}".toString())               // app generated-src
            cppFlags.add("-I${file("../../../generated-src/jni")}".toString())                   // app generated-src
            cppFlags.add("-I${file("../../../src/cpp")}".toString())
        }
    }
}

dependencies {
    compile fileTree(dir: "libs", include: ["*.jar"])
    compile "com.android.support:appcompat-v7:22.2.0"
    compile "com.android.support:design:23.1.1"
}
```

Gradle will need to sync after editing these file, and afterward you should see a ‘jni’ folder in your project browser, as well as additional files in your java folder:

![Android Studio After Gradle]({{ "/assets/images/hello-world-part-3/browser_after_gradle.png" | prepend:site.baseurl }} "Android Studio After Gradle")

## Build the App

Now we can get to coding and implement our C++ library within the Android app.

Back in Android Studio within our project, let’s edit our MainActivity file. It is likely already open, but if not it is usually located at:

**app > java > main > java.com.mycompany.helloworld > MainActivity**

Either replace the contents of the file with the code below, or add the highlighted lines:

`MainActivity.java`

```
package com.mycompany.helloworld;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private HelloWorld helloWorldInterface;

    static {
        System.loadLibrary("gnustl_shared");
        System.loadLibrary("helloworld");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        helloWorldInterface = HelloWorld.create();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void buttonWasPressed(View view) {
        String myString = helloWorldInterface.getHelloWorld() + "\n";
        TextView t = (TextView) findViewById(R.id.helloWorldText);
        t.setText(myString + t.getText());
    }
}
```

`activity_main.xml`

```
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
