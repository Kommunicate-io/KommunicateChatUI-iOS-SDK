# CHANGELOG

The changelog for [ApplozicSwift](https://github.com/AppLozic/ApplozicSwift). Also see the [releases](https://github.com/AppLozic/ApplozicSwift/releases) on Github.

2.3.1 (upcoming releases)
---
### Enhancements
- [AL-3267] Added support for blocking/unblocking a user.

### Fixes
- [AL-3302] Fix duplicate messages for open group.
- Fixed an issue where conversation details weren't getting refreshed when chat was opened from tapping on notification.
- [AL-3307] Fixed an issue where typing indicator in 1-1 chat when user was typing in group.
- [AL-3312] Fixed an issue where profile image of receiver wasn't visible for video cells.
-  Fixed an issue where video weren't being send after recording from the SDK.
- Fixed an issue where changing the right nav bar conversation icon was still refreshing the view.


2.3.0
---
### Enhancments
- Updates Swift version to 4.2
- Added Online/LastSeen status at navigation bar in conversation detail screen.
- Show loading indicator at navigation bar till conversation details are fetched.
- [AL-3206] Added support for new richMessage type : `ListTemplate` and deprecated `ALKGenericList`
- [AL-3206] Added support for new richMessage type : `CardTemplate` and deprecated `ALKGenericCard`
- [AL-3203] Removed the bubble image icon and added the corner Radius

   You can change the corner Radius like below:
```
        ALKMessageStyle.receivedBubble.cornerRadius = 12
        ALKMessageStyle.sentBubble.cornerRadius = 12

        ALKMessageStyle.receivedBubble.color = UIColor.gray
        ALKMessageStyle.sentBubble.color = UIColor.gray

        ALKMessageStyle.sentBubble.style = .edge
        ALKMessageStyle.receivedBubble.style = .edge
```     
- [AL-3229] Added caption support with image attachments. If the message(text) is present then it will be shown as caption.   
- [AL-3257] Added receive and sent message style. This is how you can change the styles:

```
        ALKMessageStyle.receivedMessage = Style(font: Font.bold(size: 14).font(), text: UIColor.red)
        ALKMessageStyle.sentMessage = Style(font: Font.italic(size: 14).font(), text: UIColor.green)
```
- Added email message support.

2.2.0
---
### Enhancments

-[AL-3196] Add a config option to disable the rich message button clicks.
- Now message key will also come in the click action for rich messages.
- Updated send button padding to make both height and width same.

### Fixes

-[AL-3224] Fixed an issue where changing background color was not updating the background of conversation view.
-[AL-3240] Fixed an where clicking mute/unmute and if the title is large then it was going out of screen.
-[AL-3241] Fixed an issue where if we update the name it was also updating the group icon.

2.1.0
---
### Enhancements

-[Al-3137] Change quick reply view to a staggered grid layout.
-[AL-3137] Added support for submit button and link button as rich messages.

### Fixes
- Fixed an issue where view was taking time in moving upwards when keyboard appears in the screen.

2.0.0
---
### Fixes

- [AL-3170] Fixed a memory leak issue in ALKConversationViewController.

### Enhancements

- [AL-2856] Dismiss Typing indicator in 30 seconds if stop flag not received
- [AL 3136] Default message meta data configuration
- Use the same bubble in case of menu click show and hide if style setting is passed

1.3.0
---
### Enhancements

- [AL-2856] Added a header view in chat bar to inject custom views from outside.
- [AL-3044] Added ALKConversationListDelegate to get chat thread selection callback.
	 And updated properties of `ALKChatViewModelProtocol` to public.
- [AL-2923] Added configure for hide start new in empty conversation
- [AL-2923] Added configure for hide back button in conversation list
- [AL-2923] Added configure for changing  color in navigation title
- [Al-3093] Update rich message layout to display message on top of templates.
- [AL-3131] Update notification to support context-based-chat.
- [AL-3088] Separate tableview from ConversationListViewController.

### Fixes

- [AL-3056] Fix an issue where earlier conversation won't load when scrolled to top.
- [AL-2923] Fix the crash for media cells for localization file name.
- [Al-3123] Fix an issue where notification will come for the message sent by the logged in user from different device.
- [AL-3117] Refresh conversationView when it is opened.

1.2.0
---
### Enhancements
- [AL-3004] Update chat screen to enable/disble chat for user when user is added/removed in the group.
- [AL-2944] Update mute functionality in conversation view.
- [AL-2922] Option to configure icon of navigation bar for conversation view and conversation list view.
- [AL-2922] Option to configure icon of send message button.
- [AL-2922] Option to configure line image visibility in chat bar.
- [AL-2922] Option to enable custom handling of navigation item click in conversation view.
- [CS-174] Update typing status to show display name of user in group conversation.
- [AL-2921] Add localization support.
- [AL-2928] UI Test case for audio recording view.

### Fixes
- [AL-3022] Fix an issue where audio option was still visible for open group.
- [AL-2973] Fix an issue where notification won't come for messages when chat screen is open.

1.1.0
---
### Fixes
- Fix position of audio-mic button. When coming back from photos screen or location screen position of mic button moves to left of screen.
- [AL-2932] Fix removal of group from chat list after group is left by swiping right on group.
- [AL-2920] Fix an issue where chat, opened from tapping on push notification, won't scroll to latest message.
- [AL-2978] Fix an issue where new one to one chat from a user would overlap all the groupChats in which this user has sent last message.
- [CS-169] Fix trimming of launch-page start to chat text in iPhone 5s.

1.0.0
---
### Enhancements
- [AL-2875] New swipe based design for audio recording.
- [AL-2769] Quick reply support in messages

### Fixes
- [AL-2909] Fix trimming of  multiline message

0.15.1
---
### Fixes
- [AL-2908] Fixed message character going out of bounds.
- [CS-127] Fixed an issue where tapping on notification was not opening chat screen.

0.15.0
---
### Enhancements

- [CS-108] Add support for contacts group.

### Fixes

- [AL-2885] Fixed a crash when tapping on add member in Create group screen.
