# ApplozicSwift


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

1. Add [ALChatManager]() file

2. Register/login:

```swift
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

3. Launch chat:

```swift
let conversationVC = ALKConversationListViewController()
let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
self.present(navVC, animated: false, completion: nil)

```


## Contributing

We would love you for the contribution to ApplozicSwift, check the LICENSE file for more info.


## License

ApplozicSwift is released under a BSD 3-Clause. See [LICENSE](LICENSE) for more information.
