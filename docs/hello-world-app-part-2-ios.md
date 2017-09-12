# "Hello World" App: Part 2, iOS

In Part 2 of this tutorial, we will create an Xcode workspace for our platform-specific iOS app code, build out a simple UI for our app in Xcode, and finally publish the app on the iOS simulator or an iOS device.

## Create an Xcode Workspace

In order for our code to be nice and organized, we’re going to need an Xcode workspace, with libraries as sub-projects. This is a similar technique that CocoaPods uses, if you are familiar with them.

To create an Xcode workspace, open up Xcode and select **File > New > Workspace**. Create a new folder in the project root called ‘ios_project’ to distinguish it from our C++ project. Save the workspace as ‘HelloWorld.xcworkspace’… the file extension may be hidden.

Now, we need to add our iOS App as a sub-project to the workspace. Select **File > New > Project** and select **iOS > Application > Single View Application**.

Set the Product Name to ‘HelloWorld’ and configure your Organization as you see fit. Be sure to pick Objective-C as the Language and be sure to add the Project to the ‘HelloWorld’ workspace:

![Add to Workspace](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/hello-world-part-2-ios/add_to_workspace.png "Add to Workspace")

Publish to make sure the workspace + project is working, the simulator should open up with the default loading screen and then a blank white screen.

## Generate iOS Libaries

Now we need to generate our Objective-C compatible libraries, using a combination of djinni, make, and gyp.

First, let’s create our GYP file.

Our GYP file will house critical information for our make commands to generate our iOS and Android library files. Create a new file at the root of the workspace:

`libhelloworld.gyp`:

```
{
    "targets": [
        {
            "target_name": "libhelloworld_jni",
            "type": "shared_library",
            "dependencies": [
              "./deps/djinni/support-lib/support_lib.gyp:djinni_jni",
            ],
            "ldflags": [ "-llog", "-Wl,--build-id,--gc-sections,--exclude-libs,ALL" ],
            "sources": [
              "./deps/djinni/support-lib/jni/djinni_main.cpp",
            ],
            "include_dirs": [
              "generated-src/jni",
              "generated-src/cpp",
              "src/cpp",
            ],
        },
        {
            "target_name": "libhelloworld_objc",
            "type": 'static_library',
            "dependencies": [
              "./deps/djinni/support-lib/support_lib.gyp:djinni_objc",
            ],
            'direct_dependent_settings': {

            },
            "sources": [
              "<!@(python deps/djinni/example/glob.py generated-src/objc  '*.cpp' '*.mm' '*.m')",
              "<!@(python deps/djinni/example/glob.py generated-src/cpp   '*.cpp')",
              "<!@(python deps/djinni/example/glob.py src '*.cpp')",
            ],
            "include_dirs": [
              "generated-src/objc",
              "generated-src/cpp",
              "src/cpp",
            ],
        },
    ],
}
```

Next, let’s create our Makefile:

*Copying and pasting the text below may result in spaces instead of tabs, which make does not agree with. I recommend copying/pasting from the Github project instead: [https://github.com/spanndemic/djinni-hello-world/blob/master/Makefile](Makefile)*

`Makefile:`

```
# we specify a root target for android to prevent all of the targets from spidering out
./build_ios/libhelloworld.xcodeproj: libhelloworld.gyp ./deps/djinni/support-lib/support_lib.gyp helloworld.djinni
  sh ./run_djinni.sh
  deps/gyp/gyp --depth=. -f xcode -DOS=ios --generator-output ./build_ios -Ideps/djinni/common.gypi ./libhelloworld.gyp

ios: ./build_ios/libhelloworld.xcodeproj
  xcodebuild -workspace ios_project/HelloWorld.xcworkspace \
           -scheme HelloWorld \
           -configuration 'Debug' \
           -sdk iphonesimulator

# we specify a root target for android to prevent all of the targets from spidering out
GypAndroid.mk: libhelloworld.gyp ./deps/djinni/support-lib/support_lib.gyp helloworld.djinni
  sh ./run_djinni.sh
  ANDROID_BUILD_TOP=$(shell dirname `which ndk-build`) deps/gyp/gyp --depth=. -f android -DOS=android -Ideps/djinni/common.gypi ./libhelloworld.gyp --root-target=libhelloworld_jni

# this target implicitly depends on GypAndroid.mk since gradle will try to make it
android: GypAndroid.mk
  cd android_project/HelloWorld/ && ./gradlew app:assembleDebug
  @echo "Apks produced at:"
  @python deps/djinni/example/glob.py ./ '*.apk'
```

*This Makefile includes an android target which will be used in the next tutorial.*

Now, with a combination of our Xcode Workspace, we can run our make command which will generate our Djinni and Hello World library files. In the Terminal app at the project root, enter the following:

```
$ make ios
```

You should now see a new directory, ‘build_ios’ with a file named ‘libhelloworld.xcodeproj’ and another (deeply-nested) file named ‘support_lib.xcodeproj’.

Add the two generated projects to the XCode Workspace… control-click on the grey area below the project navigator and select ‘add files to HelloWorld’. Again, be sure to add folder references instead of copy.

## Add the libraries to the build

Now, we need to add the libraries to our Build Phases. Click the ‘HelloWorld’ project, then select the HelloWorld target (you may need to expand the sidebar with the button in the top left). Then click the ‘Build Phases’ tab, then under Link Binaries With Libraries’, Add both `libhelloworld_objc.a` and `libdjinni_objc.a`:

![Xcode Add Libraries](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/hello-world-part-2-ios/xcode_add_libraries.png "Xcode Add Libraries")

Now, we need to add header search paths for the libraries we added. Still in the ‘HelloWorld’ target, select the ‘Build Settings’ tab. Be sure ‘All’ is selected to the left instead of ‘Basic’. Now search for ‘User Header Search Paths’ and add the following:

```
$(SRCROOT)/../../deps/djinni/support-lib/objc
$(SRCROOT)/../../generated-src/objc
```

Finally, rename the main.m file to main.mm to be compatible with our Objective-C++ bridge code. The file should be located here: HelloWorld/Supporting Files/main.m.

You should now run the project and make sure there are no errors (will still be a splash screen then a blank white screen).

## Publish to the iOS simulator or a device

Now we have all of the ingredients for our app inside the XCode workspace, and your project browser should look something like this:

![Xcode Project Dir After Libraries](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/hello-world-part-2-ios/xcode_project_dir_after_libraries.png "Xcode Project Dir After Libraries")

Only step left is to create a UI, and call our getHelloWorld function from inside our View Controller. Edit ViewController.m to be the following:

`ViewController.m`:

```
#import "ViewController.h"
#import "HWHelloWorld.h"
 
@interface ViewController ()
 
@end
 
@implementation ViewController {
    HWHelloWorld *_helloWorldInterface;
    UIButton *_button;
    UITextView *_textView;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
     
    // instantiate our library interface
    _helloWorldInterface = [HWHelloWorld create];
     
    // create a button programatically for the demo
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_button setTitle:@"Get Hello World!" forState:UIControlStateNormal];
    _button.frame = CGRectMake(20.0, 20.0, 280.0, 40.0);
    [self.view addSubview:_button];
     
    // create a text view programatically
    _textView = [[UITextView alloc] init];
    // x, y, width, height
    _textView.frame = CGRectMake(20.0, 80.0, 280.0, 380.0);
    [self.view addSubview:_textView];
     
}
 
- (void)buttonWasPressed:(UIButton*)sender
{
    NSString *response = [_helloWorldInterface getHelloWorld];
    _textView.text = [NSString stringWithFormat:@"%@\n%@", response, _textView.text];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
@end
```

Hopefully you can now publish the app (**Product > Run**) and will get a white-screen with a button labeled ‘Get Hello World!’. Pressing the button should add a line to the text view reading ‘Hello World!’ and the current time.

![iOS Complete](https://github.com/spanndemic/mobilecpptutorials.com/raw/master/images/hello-world-part-2-ios/ios_complete.png "iOS Complete")

In the next tutorial we’ll go through the same process for Android… creating a simple UI, connecting functionality and ultimately publishing to an Android device or simulator.

