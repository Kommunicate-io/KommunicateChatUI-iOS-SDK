## Migration Guides

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
   `ALKConfiguration.rightNavBarImageForConversationListView', has been deprecated. Use `ALKConfiguration.navigationItemsForConversationList` to add buttons in navigation

    ```swift
    /// ConversationList
    var navigationItemsForConversationList = [ALKNavigationItem]()

    // Example for button with text
    let buttonOne = ALKNavigationItem(identifier: 1234, text: "FAQ")

    // Adding button item in array
    navigationItemsForConversationList.append(buttonOne)

    // Example for button with icon
    let buttonTwo = ALKNavigationItem(identifier:23456, icon: UIImage(named: "icon_download", in: Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!)

    // Adding another item in array
    navigationItemsForConversationList.append(buttonTwo)

    config.navigationItemsForConversationList = navigationItemsForConversationList

    /// Add Observer to button click event callback

    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ALKNavigationItem.NSNotificationForConversationListNavigationTap), object: nil, queue: nil, using: {
    notification in

    guard let notificationUserInfo =  notification.userInfo else
    {
      return
    }

    let identifier =   notificationUserInfo["identifier"] as! Int

    print("Navigation button click for identifier in ConversationList is : ",identifier)

    })

    ```

    -  ConversationView configuration

    ```swift
    // ConversationView
     var navigationItemsForConversationView = [ALKNavigationItem]()

     let buttonOne = ALKNavigationItem(identifier: 1234, text: "FAQ")

     //Adding button item in array
      navigationItemsForConversationView.append(buttonOne)

     // Example for button with icon

     let buttonTwo = ALKNavigationItem(identifier:23456, icon: UIImage(named: "icon_download", in: Bundle(for: ALKConversationListViewController.self), compatibleWith: nil)!)

     // Adding item in array
     navigationItemsForConversationView.append(buttonOne)

     config.navigationItemsForConversationView = navigationItemsForConversationView

      ```
