## Message Template

This article will guide you how to show the custom message templates like shown in the below screenshot.

![simulator screen shot template message](https://user-images.githubusercontent.com/5956714/34526467-8c207a2c-f0c8-11e7-954a-063ac397ac71.png)


First get the sample message template file from this [link](https://github.com/AppLozic/ApplozicSwift/blob/master/Demo/message_template.json)

This is how the above json file looks:

```
{
  "templates": [
    {
      "identifier": "first",
      "text": "Hey there!"
    },
    {
      "identifier": "second",
      "text": "How are you?"
    },
    {
      "identifier": "third",
      "text": "How can I help you?"
    }
  ]
}
```

You can see `templates` is an object which contains different templates.

`identifier` is an unique string which can be used to recognize which template was selected.

`text` contains an string which is used to display the template text

You can add a number of templates like above according to your requirements. Whenever a template is selected then the message will be sent. Also, a notification will be sent with the details of the selected template. `ALKTemplateMessageModel` object which contains all the details related to a template will be sent with the notification. You can observe the notification like this:

```swift
NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "TemplateMessageSelected"), object: nil, queue: nil, using: { [weak self]
      notification in
      guard let weakSelf = self, let template = notification.object as? ALKTemplateMessageModel else { return }
      print(template.identifier)
})

```

There are two other options with each template:

First is `sendMessageOnSelection` which is true by default i.e a message will be sent on the selection of template. You can change it to `false` if you just want to receive a notification when a template was selected but don't want to send a message.

Remember: This should be set for all the templates if you want to disable message sending for all the templates.

Second option is `messageToSend`, this you should use where you want to send a different text as a message when a template is selected. If this is not set then the value of `text` will be used.
