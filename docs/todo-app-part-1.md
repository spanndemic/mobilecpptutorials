---
hero: todo-app
series: Todo App Using Djinni and SQLite
title: Todo App Using Djinni and SQLite Part 1, C++
---

In this series of tutorials, we will develop a simple cross-platform Todo List app that utilizes a SQLite database. In part 1, we will build out all of the app’s database functionality in C++.

Most every app needs a database, and it is one component of an app that most certainly can be written in C++ and utilized on both iOS and Android.

We’ll begin this tutorial much like the first Hello World tutorial, so several steps should be familiar.

*Be sure you have completed the environment setup tutorial, Cross-Platform C++ Dev Setup on OS X Yosemite.*

## Dependencies

First, let’s set up all the dependencies with Git submodules that we are able to. In terminal, enter the following commands at your project root:

```
git init
git submodule add https://github.com/dropbox/djinni.git deps/djinni
git submodule add https://chromium.googlesource.com/external/gyp.git deps/gyp
```

Then checkout the version of GYP that includes android:

```
cd deps/gyp
git checkout -q 0bb67471bca068996e15b56738fa4824dfa19de0
```

Now we need to get SQLite in the project. To do this, we are going to grab some code from the MX3 GitHub repository which will allow us to incorporate building the SQLite library into our Makefile. Download/clone the repository in a separate location, and copy the following file and folder into our ‘deps’ folder along with the git submodules:

```
deps/sqlite3/*
deps/sqlite3.gyp
```

The `sqlite3.gyp` has all the settings we will need for our SQLite library.

## Build Scripts

Much like the Hello World tutorial, we are going to need several scripts to run djinni and generate project files. I won’t go into detail about the needs of these scripts here, but if you’re curious check back on the Hello World tutorial.

Add the following files to your project root directory:

`libtodoapp.gyp:`

```
{
  "targets": [
    {
      "target_name": "libtodoapp_objc",
      "type": "static_library",
      "dependencies": [
        "./deps/djinni/support-lib/support_lib.gyp:djinni_objc",
        "./deps/sqlite3.gyp:sqlite3",
      ],
      "sources": [
        
      ],
      "include_dirs": [
        "generated-src/objc",
        "generated-src/cpp",
        "src",
      ]
    },
    {
      "target_name": "libtodoapp_jni",
      "type": "shared_library",
      "dependencies": [
        "deps/djinni/support-lib/support_lib.gyp:djinni_jni",
        "deps/sqlite3.gyp:sqlite3",
      ],
      "ldflags" : [ "-llog", "-Wl,--build-id,--gc-sections,--exclude-libs,ALL" ],
      "sources": [
        "./deps/djinni/support-lib/jni/djinni_main.cpp",
        "<!@(python deps/djinni/example/glob.py generated-src/jni   '*.cpp')",
        "<!@(python deps/djinni/example/glob.py generated-src/cpp   '*.cpp')",
        "<!@(python deps/djinni/example/glob.py src '*.cpp')",
      ],
      "include_dirs": [
        "generated-src/jni",
        "generated-src/cpp",
        "src",
      ],
    },
  ],
}
```

`Makefile`

```
./build_ios/libtodoapp.xcodeproj: libtodoapp.gyp ./deps/djinni/support-lib/support_lib.gyp todolist.djinni
  sh ./run_djinni.sh
  deps/gyp/gyp --depth=. -f xcode -DOS=ios --generator-output ./build_ios -Ideps/djinni/common.gypi ./libtodoapp.gyp

ios: ./build_ios/libtodoapp.xcodeproj
  xcodebuild -workspace ios_project/TodoApp.xcworkspace \
    -scheme TodoApp \
    -configuration 'Debug' \
    -sdk iphonesimulator

GypAndroid.mk: libtodoapp.gyp ./deps/djinni/support-lib/support_lib.gyp todolist.djinni
  sh ./run_djinni.sh
  ANDROID_BUILD_TOP=$(shell dirname `which ndk-build`) deps/gyp/gyp --depth=. -f android -DOS=android -Ideps/djinni/common.gypi ./libtodoapp.gyp --root-target=libtodoapp_jni

android: GypAndroid.mk
  cd android_project/TodoApp/ && ./gradlew app:assembleDebug
  @echo "Apks produced at:"
  @python deps/djinni/example/glob.py ./ '*.apk'

sqlite: ./build_ios/libtodoapp.xcodeproj

clean:
  rm -rf ./build_ios ./generated-src .*~ src/.*~
```

*Notice there is an additional make command for sqlite, this is because we will need to build it for our C++ test project before we build the iOS and Android projects.*

`run_djinni.sh`:

```
#! /usr/bin/env bash
 
base_dir=$(cd "`dirname "0"`" && pwd)
cpp_out="$base_dir/generated-src/cpp"
jni_out="$base_dir/generated-src/jni"
objc_out="$base_dir/generated-src/objc"
java_out="$base_dir/generated-src/java/com/mycompany/todolist"
java_package="com.mycompany.todolist"
namespace="todolist"
objc_prefix="TDA"
djinni_file="todolist.djinni"
 
deps/djinni/src/run \
   --java-out $java_out \
   --java-package $java_package \
   --ident-java-field mFooBar \
   \
   --cpp-out $cpp_out \
   --cpp-namespace $namespace \
   \
   --jni-out $jni_out \
   --ident-jni-class NativeFooBar \
   --ident-jni-file NativeFooBar \
   \
   --objc-out $objc_out \
   --objc-type-prefix $objc_prefix \
   \
   --objcpp-out $objc_out \
   \
   --idl $djinni_file
```


## Djinni file and app architecture

For the todo app, we have a bit more functionality to think about than we did in the Hello World app. We’re going to need to retrieve a list of todos from the database, as well as the ability to add, delete, and mark a todo completed.

We are going to stub out this architecture in our Djinni file, including input data types, return data types, and a record class to match our database:

`todolist.djinni`:

```
todo = record {
    id: i32;
    label: string;
    completed: i32;
}

todo_list = interface +c {
    static create_with_path(path: string): todo_list;
    get_todos(): list<todo>;
    add_todo(label: string): i32;
    update_todo_completed(id: i32, completed: i32): bool;
    delete_todo(id: i32): bool;
}
```

* ‘todo’ is our record, and corresponds to a row in the database.
* ‘todo_list’ is our app interface, containing the public api that our native UI code will use.
* the ‘create_with_path’ function is where all platforms will pass in a path to where database files live, so that our library can create the database in the appropriate place.

Now we’re going to implement the functionality we have laid out in the Djinni file with our C++ library. Add these two files to the ‘src’ directory of the project:

`todo_list_impl.hpp`:

```cpp
#pragma once

#include "todo_list.hpp"
#include "todo.hpp"
 
namespace todolist {
 
    class TodoListImpl : public TodoList {
 
    public:
 
        // Constructor
        TodoListImpl(const std::string & path);
        
        // Database functions we need to implement in C++
        std::vector<Todo> get_todos();
        int32_t add_todo(const std::string & label);
        bool update_todo_completed(int32_t id, int32_t completed);
        bool delete_todo(int32_t id);

    private:

        void _setup_db();
        void _handle_query(std::string query);
 
    };
 
}
```

`todo_list_impl.cpp`:

```cpp
#include "todo_list_impl.hpp"
#include <iostream>
#include <string>
#include <vector>
#include <sqlite3.h>
  
namespace todolist {
    
    std::string _path;
    sqlite3 *db;
    char *zErrMsg = 0;
    int rc;
    std::string sql;
    sqlite3_stmt *statement;
  
    std::shared_ptr<TodoList> TodoList::create_with_path(const std::string & path) {
        return std::make_shared<TodoListImpl>(path);
    }
    
    TodoListImpl::TodoListImpl(const std::string & path) {
        _path = path + "/todo.db";
        _setup_db();
    }
  
    std::vector<Todo> TodoListImpl::get_todos() {
        
        std::vector<Todo> todos;
        
        // get all records
        sql = "SELECT * FROM todos";
        if(sqlite3_prepare_v2(db, sql.c_str(), sql.length()+1, &statement, 0) == SQLITE_OK) {
            int result = 0;
            while(true) {
                result = sqlite3_step(statement);
                if(result == SQLITE_ROW) {
                    
                    int32_t id = sqlite3_column_int(statement, 0);
                    std::string label = (char*)sqlite3_column_text(statement, 1);
                    int32_t completed = sqlite3_column_int(statement, 2);
                    
                    Todo temp_todo = {
                        id,
                        label,
                        completed
                    };
                    todos.push_back(temp_todo);
                    
                } else {
                    break;
                }
            }
            sqlite3_finalize(statement);

        } else {
            auto error = sqlite3_errmsg(db);
            if (error!=nullptr) printf("Error: %s", error);
            else printf("Unknown Error");
        }
        
        return todos;
    }
    
    int32_t TodoListImpl::add_todo(const std::string & label) {
  
        // add a record
        sql = "INSERT INTO todos (label, completed) "  \
            "VALUES ('" + label + "', 0); ";
        _handle_query(sql);
        
        int32_t rowId = (int)sqlite3_last_insert_rowid(db);
        
        return rowId;
  
    }
    
    bool TodoListImpl::update_todo_completed(int32_t id, int32_t completed) {
        
        // update a record's status
        sql = "UPDATE todos SET completed = " + std::to_string(completed) + " " \
            "WHERE id = " + std::to_string(id) + ";";
        _handle_query(sql);
        
        return 1;
        
    }
    
    bool TodoListImpl::delete_todo(int32_t id) {
        
        // delete a record
        sql = "DELETE FROM todos WHERE id = " + std::to_string(id) + ";";
        _handle_query(sql);
        
        return 1;
        
    }
    
    // wrapper to handle errors, etc on simple queries
    void TodoListImpl::_handle_query(std::string sql) {
        rc = sqlite3_exec(db, sql.c_str(), 0, 0, &zErrMsg);
        if(rc != SQLITE_OK){
            fprintf(stderr, "SQL error: %s\n", zErrMsg);
            sqlite3_free(zErrMsg);
            return;
        }
    }
    
    void TodoListImpl::_setup_db() {
        
        // open the database, create it if necessary
        rc = sqlite3_open_v2(_path.c_str(), &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
        if(rc){
            fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
            sqlite3_close(db);
            return;
        }
        
        // create the table if it doesn't exist
        sql = "CREATE TABLE IF NOT EXISTS todos("  \
            "id INTEGER PRIMARY KEY AUTOINCREMENT    NOT NULL," \
            "label          TEXT    NOT NULL," \
            "completed         INT     NOT NULL);";
        _handle_query(sql);
        
        // check if table is empty... if so, add some data.
        sql = "SELECT * FROM todos";
        _handle_query(sql);
        if(sqlite3_prepare_v2(db, sql.c_str(), sql.length()+1, &statement, 0) == SQLITE_OK) {
            int stat = sqlite3_step(statement);
            if (stat == SQLITE_DONE) {
                // table was empty, add some data
                sql = "INSERT INTO todos (label, completed) "  \
                    "VALUES ('Learn C++', 1); " \
                    "INSERT INTO todos (label, completed) "  \
                    "VALUES ('Learn Djinni', 1); "     \
                    "INSERT INTO todos (label, completed)" \
                    "VALUES ('Write Some Tutorials', 1);" \
                    "INSERT INTO todos (label, completed)" \
                    "VALUES ('Build Some Apps', 0);" \
                    "INSERT INTO todos (label, completed)" \
                    "VALUES ('Profit', 0);";
                _handle_query(sql);
            } else {
                std::cout << "didn't add data to db\n";
            }
        } else {
            int error = sqlite3_step(statement);
            std::cout << "SQLITE not ok, error was " << error << "\n";
            
        }
        sqlite3_finalize(statement);
        
    }
  
}
```

## Build and Test in Xcode

Once again we are going to set up a C++ project in Xcode, so we get all the warm fuzzy stuff while developing such as syntax highlighting, error reporting, and unit testing if we want it.

Before we get started in Xcode, though, we need to build our SQLite library using the additional make command in our Makefile. Enter the following in the Terminal app at the project root:

```
make sqlite
```

You should now see a ‘build_ios’ folder with several different libraries. We only need the build_ios/deps/sqlite3.xcodeproj library for now.

Create a new Xcode Project, choosing OSX Command Line Tool Application and C++ as the language. Name the project ‘TodoApp’ and place it in a new folder ‘cpp_project’ in our project directory. Then add the following files to the project, in the same folder as the main.cpp file. Be sure to create folder references instead of copying, and to add the files to your deployment target:

```
build_ios/deps/sqlite3.xcodeproj
generated-src/cpp/todo_list.hpp
generated-src/cpp/todo.hpp
src/todo_list_impl.cpp
src/todo_list_impl.hpp
```

Also add the sqlite library to your ‘Build Phases’ of your app target.

Now, your xcode project browser should look like the following:

![Todo App C++ Xcode Browser](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/todo-app-part-1/todo_app_cpp_xcode_browser.png "Todo App C++ Xcode Browser")

Our last step is to modify main.cpp to actually test our code. Replace the contents of the file with the following:

`main.cpp`


```cpp
#include <iostream>
#include "todo.hpp"

#include <stdio.h>
#include <sqlite3.h>
#include <string>
#include "todo_list_impl.hpp"

void print_todos(todolist::TodoListImpl tdl) {
    std::vector<todolist::Todo> todos = tdl.get_todos();
    for (auto & element : todos) {
        std::cout << element.id << ". " << element.label << " (" << element.completed << ")\n";
    }
}

int main(int argc, char **argv){
    
    // instantiate our C++ implementation
    todolist::TodoListImpl tdl = todolist::TodoListImpl(".");
    
    // print the initial list
    std::cout << "Initial Todos:\n";
    print_todos(tdl);
    
    // add a thing
    std::string myThing = "New Todo";
    int newId = tdl.add_todo(myThing);
    
    // show updated todos
    std::cout << "\nTodo Added:\n";
    print_todos(tdl);
    
    // update the new thing's status to complete
    tdl.update_todo_completed(newId, 1);
    
    // show updated todos
    std::cout << "\nTodo Completed:\n";
    print_todos(tdl);
    
    // delete the thing
    tdl.delete_todo(newId);
    
    // show updated todos
    std::cout << "\nTodo Deleted:\n";
    print_todos(tdl);
    
    return 0;
    
}
```

Now if you run the app, you should see output similar to the following, demonstrating the add/edit/delete functionality of our database:

```
Initial Todos:
1. Learn C++ (1)
2. Learn Djinni (1)
3. Write Some Tutorials (1)
4. Build Some Apps (0)
5. Profit (0)

Todo Added:
1. Learn C++ (1)
2. Learn Djinni (1)
3. Write Some Tutorials (1)
4. Build Some Apps (0)
5. Profit (0)
6. New Todo (0)

Todo Completed:
1. Learn C++ (1)
2. Learn Djinni (1)
3. Write Some Tutorials (1)
4. Build Some Apps (0)
5. Profit (0)
6. New Todo (1)

Todo Deleted:
1. Learn C++ (1)
2. Learn Djinni (1)
3. Write Some Tutorials (1)
4. Build Some Apps (0)
5. Profit (0)
```

Congratulations! you’ve now got a C++ library with database functionality ready to go for the native UI of both your Android and IOs apps.

Now check out Part 2 of this tutorial where we build our iOS UI and publish to an iOS device or simulator.



