## Migration Guides

### Migrating from versions <= 5.5.0

#### Removed the deprecated configuration for navigation bar

The configuration for changing `navigationBarTitleColor`, `navigationBarBackgroundColor`, `navigationBarItemColor` has been removed from `ALKConfiguration`.

Instead use `UINavigationBar.appearance` to change the navigation bar title, background and bar item color

```swift
let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])
      /// Background color
      navigationBarProxy.barTintColor
          = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1.0)
      /// Title text color
      navigationBarProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      navigationBarProxy.isTranslucent = false
      /// Icons tint color
      navigationBarProxy.tintColor = .white
```
### Migrating from versions <= 5.1.1

#### Date separator and channel info messages style customization

- `ALKConfiguration.conversationViewCustomCellTextColor`, has been deprecated. Use style `ALKMessageStyle.infoMessage` or `ALKMessageStyle.dateSeparator`.

- `ALKConfiguration.conversationViewCustomCellBackgroundColor`, has been deprecated. Use style `ALKMessageStyle.infoMessage` or `ALKMessageStyle.dateSeparator`.

Use below config for changing the style for date cell or channel info messages.
</br>

For example to change the style in date separator you can config as below:
```swift
ALKMessageStyle.dateSeparator = Style(font: UIFont.systemFont(ofSize: 12), text: UIColor.black, background: .red)
```
For example to change the style for channel info messages you can config as below:
 ```swift
 ALKMessageStyle.infoMessage = Style(font: UIFont.systemFont(ofSize: 12), text: UIColor.black , background: .red)
 ```

### Migrating from versions < 3.4.0

#### Navigation Bar Customization

- `ALKConfiguration.navigationBarBackgroundColor`, has been deprecated. Use `UIAppearance` for navigation bar configuration.
- `ALKConfiguration.navigationBarItemColor`, has been deprecated. Use `UIAppearance` for navigation bar configuration.
- `ALKConfiguration.navigationBarTitleColor`, has been deprecated. Use `UIAppearance` for navigation bar configuration.

If you are using `ALKBaseNavigationViewController` to present the conversation then, you can customize it like this:

```swift
// Use `appearance(whenContainedInInstancesOf:)` method to limit the changes to instances of `ALKBaseNavigationViewController`.
let navigationBarProxy = UINavigationBar.appearance(whenContainedInInstancesOf: [ALKBaseNavigationViewController.self])

navigationBarProxy.tintColor = UIColor.blue
navigationBarProxy.barTintColor = UIColor.gray
navigationBarProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // title color
```

### Migrating from versions < 3.1.0

####  ChatBar Configuration
- `ALKConfiguration.hideContactInChatBar`, has been deprecated. Use `ALKConfiguration.chatBar.showOptions` to only show some options.

    ```swift
    config.optionsToShow = .some([.gallery, .location, .camera, .video])
    ```
- `ALKConfiguration.hideAllOptionsInChatBar` has been deprecated. Use `ALKConfiguration.chatBar.showOptions` to hide the all attachment options.

    ```swift
    configuration.chatBar.optionsToShow = .none
    ```

####  Navigation button Configuration

  -  ConversationList configuration
   `ALKConfiguration.rightNavBarImageForConversationListView`, has been deprecated. Use `ALKConfiguration.navigationItemsForConversationList` to add buttons in the navigation bar

  ```swift
    // ConversationList
    var navigationItemsForConversationList = [ALKNavigationItem]()

    // Example for button with text
    let buttonOne = ALKNavigationItem(identifier: 1234, text: "FAQ")

    // Adding an item in the list
    navigationItemsForConversationList.append(buttonOne)

    // Example for button with icon
    let buttonTwo = ALKNavigationItem(identifier:23456, icon: UIImage(named: "icon_download", in: Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!)

    // Adding an item in the list
    navigationItemsForConversationList.append(buttonTwo)

    config.navigationItemsForConversationList = navigationItemsForConversationList

    // Add an Observer to get the event callback
    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: nil, queue: nil, using: { notification in

        guard let notificationUserInfo = notification.userInfo else { return }
        let identifier =   notificationUserInfo["identifier"] as! Int
        print("Navigation button click for identifier in ConversationList is : ",identifier)
    })
  ```

  -  ConversationView configuration

  ```swift
    // ConversationView
    var navigationItemsForConversationView = [ALKNavigationItem]()

    let buttonOne = ALKNavigationItem(identifier: 1234, text: "FAQ")

    // Adding an item in the list
    navigationItemsForConversationView.append(buttonOne)

    // Example for button with icon
    let buttonTwo = ALKNavigationItem(identifier:23456, icon: UIImage(named: "icon_download", in: Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!)

    // Adding an item in the list
    navigationItemsForConversationView.append(buttonOne)

    config.navigationItemsForConversationView = navigationItemsForConversationView
  ```
