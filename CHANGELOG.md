# CHANGELOG

The changelog for [ApplozicSwift](https://github.com/AppLozic/ApplozicSwift). Also see the [releases](https://github.com/AppLozic/ApplozicSwift/releases) on Github.

1.3.0(upcoming release)
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
