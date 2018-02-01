## ContextTitleView

This article will guide you how to subclass the `ALKContextTitleView` class and customize it according to your requirements.

![simulator screen shot context title view ](https://user-images.githubusercontent.com/5956714/35631016-cefd93e6-06c8-11e8-9b7e-803850f6c4a7.png)

### Subclass and Modify the UI

```swift

class TitleContextView: ALKContextTitleView {


    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()
        titleLabel.isHidden = true
        titleLabel.backgroundColor = UIColor.black
    }
}
```


### Inject the Subclassed view

```swift

class ConversationVC: ALKConversationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = TitleContextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.contextTitleView = view
    }
}

class ConversationListVC: ALKConversationListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationViewController = ConversationVC()

    }
}

```
