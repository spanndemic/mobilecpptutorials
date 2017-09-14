---
series: Todo App Using Djinni and SQLite
title: Todo App Using Djinni and SQLite Part 3, Android
hero: todo-app
image-credit: Patrick Metzdorf
image-credit-link: https://www.flickr.com/photos/batjko/13515152514/
date: August 27, 2015
redirect_from:
  - /todo-app-using-djinni-and-sqlite-part-3-android/
---

In this tutorial we will utilize our C++ back-end in Java, build an Android UI, and finally publish to an Android device or simulator.

## Create a New Android Project

Open up Android Studio, and select ‘Start a new Android Studio project’ from the Quick Start menu on the splash screen, or select File > New > New Project from the top navigation.

On the info screen, enter the following:

Application Name: Todo App

Company Domain: mycompany.com

Project Location: Create a new folder inside your project, here I’ve chosen ‘android_project’ to be consistent with our other Xcode project naming:

![Todo Android Setup](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/todo-app-part-3/todo_android_setup.png "Todo Android Setup")

*The company name is important here because it is used as the package name throughout this tutorial.*

For the remaining screens in the wizard (Form Factors, Add an Activity, and Customize the Activity), just click ‘Next’ or ‘Finish’ to keep the defaults.

## Project Files

We’ll once again need to modify our gradle/project build files in order to utilize our C++ libraries. Add the following two files to your project via your preferred text editor:

`Android.mk`:

```
# always force this build to re-run its dependencies
FORCE_GYP := $(shell make -C ../../../GypAndroid.mk)
include ../../../GypAndroid.mk
```

`Application.mk`:

```
# Android makefile for helloworld shared lib, jni wrapper around libhelloworld C API
 
APP_ABI := all
APP_OPTIM := release
APP_PLATFORM := android-9
# GCC 4.9 Toolchain
NDK_TOOLCHAIN_VERSION = 4.9
# GNU libc++ is the only Android STL which supports C++11 features
APP_STL := c++_static
APP_BUILD_SCRIPT := jni/Android.mk
APP_MODULES := libtodoapp_jni
```

*You may need to adjust the NDK_TOOLCHAIN_VERSION value for future versions of the NDK.*

Also modify your build.gradle file to add the highlighted lines below, or replace the contents with the following:

`app/build.gradle`:

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

Now run the Android make script by entering the following in the Terminal app in the root folder of the project:

```
$ make android
```

Reopen the Android Studio project, and you should see a new ‘jniLibs’ folder that has our libtodolist_jni.so files for each architecture. While Android Studio is open, you may get a message about needing to sync, go ahead and do this and the ‘jniLibs’ folder should appear.

## Building the Android UI

Now that we have our C++ code available to us in our Android app, we need to build the native interface code for the app and connect the functionality to our C++ library.

First let’s build our interface with a ListView and a custom row, to match our UITableView in iOS:

`activity_main.xml`

```
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" android:layout_width="match_parent"
    android:layout_height="match_parent" android:paddingLeft="@dimen/activity_horizontal_margin"
    android:paddingRight="@dimen/activity_horizontal_margin"
    android:paddingTop="@dimen/activity_vertical_margin"
    android:paddingBottom="@dimen/activity_vertical_margin" tools:context=".MainActivity">

    <Button android:id="@+id/addButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:text="Add Todo"
        android:onClick="addButtonPressed" />


    <ListView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_below="@+id/addButton"
        android:id="@android:id/list"
        android:background="#ffffff" />

</RelativeLayout>
```

Then create a new file (right-click on the ‘layout’ folder, and name the file ‘row_layout.xml’) for our row and replace the content with the following:

`row_layout.xml`:

```
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="horizontal">

    <TextView
        android:id="@+id/listText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:padding="10dp"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="#000000" />

    <Button
        android:id="@+id/deleteButton"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Delete"
        android:focusable="false"
        android:layout_alignParentRight="true"
        android:onClick="deleteButtonPressed" />

</RelativeLayout>
```

Finally let’s update our MainActivity to load our JNI library and connect the UI with our database logic:

`MainActivity.java`:

```
package com.mycompany.todoapp;

import android.app.ListActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.ListView;

import com.mycompany.todolist.Todo;
import com.mycompany.todolist.TodoList;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends ListActivity {

    private TodoList todoListInterface;
    private List<String> listValues;
    ArrayList<Todo> todos;
    private int newTodoCount = 1;


    static {
        System.loadLibrary("todoapp_jni");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        listValues = new ArrayList<String>();

        String dbPath = this.getFilesDir().getAbsolutePath();
        todoListInterface = TodoList.createWithPath(dbPath);
        refreshList();

    }

    protected void refreshList() {
        todos = todoListInterface.getTodos();
        listValues = new ArrayList<String>();

        for (int i = 0; i < todos.size(); i++) {

            Todo todo = todos.get(i);

            if (todo.getCompleted() == 1) {
                listValues.add("X  " + todo.getLabel());
            } else {
                listValues.add("     " + todo.getLabel());
            }
        }

        ArrayAdapter<String> myAdapter = new ArrayAdapter <String>(this,
                R.layout.row_layout, R.id.listText, listValues);
        setListAdapter(myAdapter);

    }


    // when an item of the list is clicked
    @Override
    protected void onListItemClick(ListView list, View view, int position, long id) {

        super.onListItemClick(list, view, position, id);
        Todo selectedTodo = (Todo) todos.get(position);

        // toggle selected item
        if (selectedTodo.getCompleted() == 1) {
            todoListInterface.updateTodoCompleted(selectedTodo.getId(), 0);
        } else {
            todoListInterface.updateTodoCompleted(selectedTodo.getId(), 1);
        }

        refreshList();

    }

    public void addButtonPressed(View view) {

        todoListInterface.addTodo("New Todo " + String.valueOf(newTodoCount));
        newTodoCount++;

        refreshList();
    }


    public void deleteButtonPressed(View view) {

        ListView listView = getListView();

        final int position = listView.getPositionForView((View) view.getParent());

        // get database id
        Todo selectedTodo = (Todo) todos.get(position);

        todoListInterface.deleteTodo(selectedTodo.getId());

        refreshList();
    }

}
```

## Publish to an Android device/simulator

Now you should be able to publish the app, and see the working Todo App. Try adding, checking, and deleting things, plus closing and reopening the app to see that the data is persistent. Note: if you delete everything in the list, the next time the app runs it will repopulate with the original five todos.

![Todo Android Complete](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/todo-app-part-3/todo_android_complete.png "Todo Android Complete")

## Conclusion

I hope this series of tutorials has helped you out, if you run into any issues feel free to contact me at stephenspann@gmail.com.

