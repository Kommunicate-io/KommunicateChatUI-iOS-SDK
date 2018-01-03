## ALKConversationViewController

This article will guide you how to subclass the `ALKConversationViewController` class and customize it according to your requirements.

### Subclass ALKConversationViewController

You can subclass it like this:

```swift
class ConversationVC: ALKConversationViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Your code
    }
}
```

If you are opening a single chat thread then use the subclassed class like this:

```swift
let alContactDbService = ALContactDBService()
var title = ""
if let alContact = alContactDbService.loadContact(byKey: "userId", value: contactId), let name = alContact.getDisplayName() {
    title = name
}
title = title.isEmpty ? "No name":title
let convViewModel = ALKConversationViewModel(contactId: contactId, channelKey: nil)
let conversationViewController = ConversationVC()
conversationViewController.title = title
conversationViewController.viewModel = convViewModel
viewController.navigationController?.pushViewController(conversationViewController, animated: false)
```

If you want to open the chat list then you will have to inject the above subclassed class in the ALKConversationListViewController like this:

```swift
let conversationListVC = ALKConversationListViewController()
conversationListVC.conversationViewControllerType = ConversationVC.self
let navVC = ALKBaseNavigationViewController(rootViewController: conversationListVC)
viewController.present(navVC, animated: false, completion: nil)
```

### Set Background Color/Image

Once you have subclassed the `ALKConversationViewController` class then in the `viewWillAppear` you can update it like this:

```swift
override func viewWillAppear(_ animated: Bool) {
    backgroundView.backgroundColor = UIColor.blue
    super.viewWillAppear(animated)
}
```

If you want to add an image to the background then you can assign an imageView to the backgroundView property like this:

```swift
override func viewWillAppear(_ animated: Bool) {
    let imageview = UIImageView(frame: CGRect.zero)
    let image = UIImage(named: "wallpaper")
    imageview.image = image
    self.backgroundView = imageview
    super.viewWillAppear(animated)
}
```
