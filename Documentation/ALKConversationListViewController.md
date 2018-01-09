## ALKConversationListViewController

This article will guide you how to subclass the `ALKConversationListViewController` class and customize it according to your requirements.

### Subclass ALKConversationListViewController

You can subclass it like this:

```swift
class ConversationVC: ALKConversationListViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Your code
    }
}
```

### Remove the placeholder

![empty chat placeholder](https://user-images.githubusercontent.com/5956714/34710396-2c3309fe-f541-11e7-8587-23d07872c2c7.png)

To remove the above start chat placeholder you have to set the tableview's footer as nil:

```swift
class ConversationListVC: ALKConversationListViewController {

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
```
