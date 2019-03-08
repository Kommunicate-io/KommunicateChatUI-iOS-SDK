# ApplozicSwift

[![Version](https://img.shields.io/cocoapods/v/ApplozicSwift.svg?style=flat)](http://cocoapods.org/pods/ApplozicSwift)
![iOS 8.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)
[![License](https://img.shields.io/cocoapods/l/Material.svg?style=flat)](https://github.com/lkzhao/Material/blob/master/LICENSE?raw=true)

UI kit for Applozic SDK, written completely in Swift.

## Overview

Open source iOS Chat and Messaging SDK that lets you add real time messaging in your mobile (android, iOS) applications and website.

Signup at https://www.applozic.com/signup.html to get the application key.

------------------------

![Screenshot0][img0] &nbsp;&nbsp; ![Screenshot1][img1] &nbsp;&nbsp;

![Screenshot2][img2] &nbsp;&nbsp;

## Sample Project

There's a sample project in the Demo directory. To use it, run `pod install` to download the required libraries. Have fun!

## Project Status

This project is actively under development.

## Installation

### CocoaPods

For ApplozicSwift, use the following entry in your Podfile:

`pod 'ApplozicSwift'`

Then run `pod install`.

In any file you'd like to use ApplozicSwift in, don't forget to
import the framework with `import ApplozicSwift`.

### Manually

- Open up Terminal, `cd` into your top-level project directory, and run the following command *if* your project is not initialized as a git repository:

```bash
$ git init
```

- Add ApplozicSwift, Applozic, Kingfisher & MGSwipeTableCell as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following commands:

```bash
$ git submodule add https://github.com/AppLozic/ApplozicSwift
$ git submodule add https://github.com/AppLozic/Applozic-iOS-SDK
$ git submodule add https://github.com/onevcat/Kingfisher.git
$ git submodule add https://github.com/MortimerGoro/MGSwipeTableCell.git
```

- Open the new `ApplozicSwift` folder, and drag the `ApplozicSwift.xcodeproj` into the Project Navigator of your application's Xcode project. Do the same with the `Applozic.xcodeproj` in the `Applozic` folder, `Kingfisher.xcodeproj` in the `Kingfisher` folder and `MGSwipeTableCell.xcodeproj` in the `MGSwipeTableCell` folder.

> They should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Verify that the deployment targets of the `xcodeproj`s match that of your application target in the Project Navigator.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under "Embedded Binaries" again and add the build target you need for `ApplozicSwift`.
- Click on the `+` button under "Embedded Binaries" again and add the build target you need for `Applozic`.
- Click on the `+` button under "Embedded Binaries" again and add the build target you need for `KingFisher`.
- Click on the `+` button again and add the correct build target for `MGSwipeTableCell`.

- And that's it!

> The four frameworks are automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Usage

#### ChatManager

Add the [ALChatManager](https://github.com/AppLozic/ApplozicSwift/blob/master/Demo/ApplozicSwiftDemo/ALChatManager.swift) file in your project. It contains the convenient methods required to handle the chat like registration, opening chat list etc.

#### Registration

```swift
// Use the same API for login
let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
alChatManager.registerUser(alUser, completion: {response, error in
      if error == nil {
          NSLog("[REGISTRATION] Applozic user registration was successful: %@ \(response?.isRegisteredSuccessfully())")
          // Launch chat
      } else {
          NSLog("[REGISTRATION] Applozic user registration error: %@", error.debugDescription)
      }
})
```

#### Launch chat list

```swift
let alChatManager = ALChatManager(applicationKey: <Application key>, with: ALKConfiguration())
alChatManager.launchChatList(from: self)
```

#### Launch Group

```swift
let alChatManager = ALChatManager(applicationKey: <Application key>, configuration: ALKConfiguration())
alChatManager.launchGroupWith(clientGroupId: <groupId>, from: self)
```


#### Launch Individual Chat

```swift
let alChatManager = ALChatManager(applicationKey: <Application key>, configuration: ALKConfiguration())
alChatManager.launchChatWith(contactId: <userId>, from: self)
```


## Requirements

* iOS 9.0+
* Xcode 10.0+
* Swift versions :: 
< 4.0 - Use framework version below 1.1.0
>= 4.0 - Use framework version starting from 1.1.0

## Contributing

We would love you for the contribution to ApplozicSwift, check the LICENSE file for more info.


## License

ApplozicSwift is released under a BSD 3-Clause. See [LICENSE](LICENSE) for more information.

[img0]:https://raw.githubusercontent.com/Applozic/ApplozicSwift/master/Screenshots/screenshot0.png
[img1]:https://raw.githubusercontent.com/Applozic/ApplozicSwift/master/Screenshots/screenshot1.png
[img2]:https://raw.githubusercontent.com/Applozic/ApplozicSwift/master/Screenshots/screenshot2.png
