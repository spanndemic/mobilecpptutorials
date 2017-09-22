---
series: Hello World App
title: Hello World App Part 2, iOS
hero: hello-world-app
image-credit: Toni Rodrigo
image-credit-link: https://www.flickr.com/photos/tonirodrigo/2482188903/
redirect_from:
  - /your-first-cross-platform-djinni-app-part-2-ios/
---

In Part 2 of this tutorial, we will add a target to our Xcode workspace for our platform-specific iOS app code, build out a simple UI for our app in Xcode, and finally publish the app on the iOS simulator or an iOS device.

## Add an iOS Target to the Xcode Project

To add a new target to our Xcode project, select **File > New > Target...**, then select **iOS** and scroll down to **Application > Single View Application** in the template menu, then click 'Next':

![iOS Add Target]({{ "/assets/images/hello-world-part-2/ios_add_target.png" | prepend:site.baseurl }} "iOS Add Target")

In the following dialog, enter the name 'Hello World iOS' for the target name. Also uncheck 'Include Unit Tests' and 'Include UI Tests' to avoid creating additional targets and to keep our project tidy:

![New Target Options]({{ "/assets/images/hello-world-part-2/new_target_options.png" | prepend:site.baseurl }} "New Target Options")

In order to switch between publishing our C++ app and our iOS app, we will need to change schemes. Switch to they 'Hello World iOS' scheme with the dropdown next to the Play/Stop buttons. You'll also select need to select a simulator. I'm using the iPhone 5S here because it is a little less enormous than the others:

![iOS Change Scheme]({{ "/assets/images/hello-world-part-2/ios_change_scheme.png" | prepend:site.baseurl }} "iOS Change Scheme")

Finally, run the default iOS app in the simulator by pressing the 'Play' button, and you should have the simulator open up with a blank white screen and no errors.

## Add our C++ Source and Objective-C Bridge code to the iOS Target

Since our our C++ Source is already in the Xcode Project, we can simply add our C++ source files to the new iOS target. To do this, highlight the file `hello_world_impl.cpp` and find the 'Target Membership' menu on the right side of the screen. Be sure that 'Hello World C++' and 'Hello World iOS' are both checked. Note that you do not need to add the header files (`.hpp`):

![Add Src to Target]({{ "/assets/images/hello-world-part-2/add_src_to_target.png" | prepend:site.baseurl }} "Add Src to Target")

Next, let's add the rest of the bridge code that Djinni generated for iOS to communicate with C++. Drag the following files into Xcode’s folder structure, inside the **Hello World iOS** project folder in a new group named 'Bridge':

```
generated-src/objc/HWHelloWorld.h
generated-src/objc/HWHelloWorld+Private.h
generated-src/objc/HWHelloWorld+Private.mm
```

You will get a similar dialog to the C++ files, select 'Create folder references' and select the 'Hello World iOS' target. You do not need to add these files to the previous C++ target.

*Note that a `.mm` file extension signifies a file that can include both Objective-C and C++ code... also known as Objective-C++.*

We'll also need some additional Djinni source files, drag and drop the contents of the `deps/djinni/support-lib/objc/` folder into the project as well into a folder labeled 'Djinni':

```
deps/djinni/support-lib/objc/DJICppWrapperCache+Private.h
deps/djinni/support-lib/objc/DJIError.h
deps/djinni/support-lib/objc/DJIError.mm
deps/djinni/support-lib/objc/DJIMarchal+Private.h
deps/djinni/support-lib/objc/DJIObjcWrapperCache+Private.h
deps/djinni/support-lib/objc/DJIProxyCaches.h
```

Finally, click the `main.m` filename and rename it to `main.mm` to be compatible with our Objective-C++ bridge code. The file should be located here: `HelloWorld/Supporting Files/main.m`:

![iOS Rename Main]({{ "/assets/images/hello-world-part-2/ios_rename_main.png" | prepend:site.baseurl }} "iOS Rename Main")

Your project should now have all of the following source files available:

![iOS After Bridge]({{ "/assets/images/hello-world-part-2/ios_rename_main.png" | prepend:site.baseurl }} "iOS After Bridge")

You should now run the project and make sure there are no errors... though the simulator screen will still just show a blank white screen!

## Publish to the iOS simulator or a device

Our last step is to create a UI that interacts with our C++ code. Edit `ViewController.m` to be the following:

`ViewController.m`:

```obj-c
#import "ViewController.h"
#import "HWHelloWorld.h"
 
@interface ViewController ()
 
@end
 
@implementation ViewController {
    HWHelloWorld *_cppApi;
    UIButton *_button;
    UITextView *_textView;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
     
    // instantiate our library interface
    _cppApi = [HWHelloWorld create];
     
    // create a button programatically for the demo
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_button setTitle:@"Get Hello World!" forState:UIControlStateNormal];
    _button.frame = CGRectMake(20.0, 20.0, 280.0, 40.0);
    [self.view addSubview:_button];
     
    // create a text view programatically
    _textView = [[UITextView alloc] init];
    _textView.frame = CGRectMake(20.0, 80.0, 280.0, 380.0);
    [self.view addSubview:_textView];
     
}
 
- (void)buttonWasPressed:(UIButton*)sender
{
    NSString *response = [_cppApi getHelloWorld];
    _textView.text = [NSString stringWithFormat:@"%@\n%@", response, _textView.text];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
@end
```

Now when you publish the app (**Product > Run** or the 'Play' button), you should get a white-screen with a button labeled ‘Get Hello World!’. Pressing the button should add a line to the text view reading ‘Hello World!’ and the current time, which was generated by our C++ code in Part 1 of this tutorial:

![iOS Complete]({{ "/assets/images/hello-world-part-2/ios_complete.png" | prepend:site.baseurl }} "iOS Complete")

In the next tutorial we’ll go through the same process for Android... creating a simple UI, connecting functionality and ultimately publishing to an Android device or simulator.

