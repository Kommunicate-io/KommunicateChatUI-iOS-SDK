//
//  SystemMessage.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

//handle all in app's display messages
struct SystemMessage : Localizable{

    struct Camera {
        static let cameraPermission = localizedString(forKey: "EnableCameraPermissionMessage")
        static let CamNotAvailable = localizedString(forKey: "CameraNotAvailableMessage")
        static let camNotAvailableTitle = localizedString(forKey: "CameraNotAvailableTitle")
        static let GalleryAvailable = localizedString(forKey: "GalleryNotAvailableMessage")
        static let PictureCropped = localizedString(forKey: "ImageCroppedMessage")
        static let PictureReset = localizedString(forKey: "ImageResetMessage")
        static let PleaseAllowCamera = localizedString(forKey: "PleaseAllowCamera")
    }

    struct Microphone {
        static let MicNotAvailable = localizedString(forKey: "MicrophoneNotAvailableMessage")
        static let PleaseAllowMic = localizedString(forKey: "AllowSoundRecordingMessage")
        static let SlideToCancel = localizedString(forKey: "SlideToCancelMessage")
        static let Recording = localizedString(forKey: "RecordingMessage")
    }

    struct Map {
        static let NoGPS = localizedString(forKey: "TurnGPSOnMessage")
        static let MapIsLoading = localizedString(forKey: "MapLoadingMessage")
        static let AllowPermission = localizedString(forKey: "AllowGPSMessage")
        static let TurnOnLocationService = localizedString(forKey: "TurnOnLocationService")
        static let LocationAlertMessage = localizedString(forKey: "LocationAlertMessage")
        static let ShareLocationTitle = localizedString(forKey: "ShareLocationTitle")
        static let SendLocationButton = localizedString(forKey: "SendLocationButton")
    }

    struct Information {
        static let FriendAdded = localizedString(forKey: "FriendAddedMessage")
        static let FriendRemoved = localizedString(forKey: "FriendRemovedMessage")
        static let AppName = ""
        static let NotPartOfGroup = localizedString(forKey: "NotPartOfGroup")
        static let ChatHere = localizedString(forKey: "ChatHere")
    }

    struct Update {
        static let CheckRequiredField = localizedString(forKey: "CheckImageAndNameField")
        static let UpdateMood = localizedString(forKey: "UpdateMoodMessage")
        static let UpdateProfileName = localizedString(forKey: "UpdateProfileSuccessMessage")
        static let Failed = localizedString(forKey: "FailedToUpdateMessage")
    }

    struct Warning {
        static let NoEmail = localizedString(forKey: "EnterEmailMessage")
        static let InvalidEmail = localizedString(forKey: "InvalidEmailMessage")
        static let FillInAllFields = localizedString(forKey: "Please fill-in all fields")
        static let FillInPassword = localizedString(forKey: "FillPasswordMessage")
        static let PasswordNotMatched = localizedString(forKey: "PasswordNotMatchedMessage")
        static let CamNotAvaiable = localizedString(forKey: "CamNotAvaiable")
        static let Cancelled = localizedString(forKey: "CancelMessage")
        static let PleaseTryAgain = localizedString(forKey: "ConnectionFailedMessage")
        static let FetchFail = localizedString(forKey: "FetchFailedMessage")
        static let OperationFail = localizedString(forKey: "OperationFailedMessage")
        static let DeleteSingleConversation = localizedString(forKey: "DeleteSingleConversation")
        static let LeaveGroupConoversation = localizedString(forKey: "LeaveGroupConversation")
        static let DeleteGroupConversation = localizedString(forKey: "DeleteGroupConversation")
        static let DeleteContactWith = localizedString(forKey: "RemoveMessage")
        static let DownloadOriginalImageFail = localizedString(forKey: "DownloadOriginalImageFail")
        static let ImageBeingUploaded = localizedString(forKey: "UploadingImageMessage")
        static let SignOut = localizedString(forKey: "SignOutMessage")
        static let FillGroupName = localizedString(forKey: "FillGroupName")
        static let DiscardChange = localizedString(forKey: "DiscardChangeMessage")
    }

    struct ButtonName {
        static let SignOut = localizedString(forKey: "SignOutButtonName")
        static let Retry = localizedString(forKey: "RetryButtonName")
        static let Remove = localizedString(forKey: "RemoveButtonName")
        static let Leave = localizedString(forKey: "LeaveButtonName")
        static let Cancel = localizedString(forKey: "ButtonCancel")
        static let Discard = localizedString(forKey: "ButtonDiscard")
        static let Save = localizedString(forKey: "SaveButtonTitle")
        static let ResetPhoto = localizedString(forKey: "ResetPhotoButton")
        static let Select = localizedString(forKey: "SelectButton")
        static let Done = localizedString(forKey: "DoneButton")
        static let Invite = localizedString(forKey: "InviteButton")
        static let Confirm = localizedString(forKey: "ConfirmButton")
    }

    struct NoData {
        static let NoName = localizedString(forKey: "NoNameMessage")
    }

    struct UIError {
        static let unspecifiedLocation = localizedString(forKey: "UnspecifiedLocation")
    }

    struct PhotoAlbum {
        static let Success  = localizedString(forKey: "PhotoAlbumSuccess")
        static let Fail     = localizedString(forKey: "PhotoAlbumFail")
        static let SuccessTitle = localizedString(forKey: "PhotoAlbumSuccessTitle")
        static let FailureTitle = localizedString(forKey: "PhotoAlbumFailureTitle")
        static let Ok = localizedString(forKey: "PhotoAlbumOk")
    }

    struct Message {
        static let isTypingForRTL = localizedString(forKey: "IsTypingForRTL")
        static let isTyping = localizedString(forKey: "IsTyping")
        static let areTyping = localizedString(forKey: "AreTyping")
    }

    struct ChatList {
        static let title = localizedString(forKey: "ConversationListVCTitle")
        static let NoConversationsLabelText = localizedString(forKey: "NoConversationsLabelText")
        static let leftBarBackButton = localizedString(forKey: "Back")
    }

    struct Chat {
        static let somebody = localizedString(forKey: "Somebody")
    }

    struct NavbarTitle {
        static let createGroupTitle = localizedString(forKey: "CreateGroupTitle")
        static let editGroupTitle = localizedString(forKey: "EditGroupTitle")
    }

    struct LabelName {
        static let Edit = localizedString(forKey: "Edit")
        static let Participants = localizedString(forKey: "Participants")
        static let TypeGroupName = localizedString(forKey: "TypeGroupName")
        static let SendPhoto = localizedString(forKey: "SendPhoto")
        static let Settings = localizedString(forKey: "Settings")
        static let Camera = localizedString(forKey: "Camera")
        static let Cancel = localizedString(forKey: "Cancel")
        static let CropImage = localizedString(forKey: "CropImage")
        static let Photos = localizedString(forKey: "PhotosTitle")
        static let SendVideo = localizedString(forKey: "SendVideo")
        static let SearchPlaceholder = localizedString(forKey: "SearchPlaceholder")
        static let NewChatTitle = localizedString(forKey: "NewChatTitle")
        static let AddToGroupTitle = localizedString(forKey: "AddToGroupTitle")
        static let InviteMessage = localizedString(forKey: "InviteMessage")
        static let DiscardChangeTitle = localizedString(forKey: "DiscardChangeTitle")
        static let NotNow = localizedString(forKey: "NotNow")
        static let Copy = localizedString(forKey: "Copy")
        static let Reply = localizedString(forKey: "Reply")
        static let You = localizedString(forKey: "You")
    }


    struct Mute {
        static let MuteUser = localizedString(forKey: "MuteUser")
        static let MuteChannel = localizedString(forKey: "MuteChannel")
        static let UnmuteUser = localizedString(forKey: "UnmuteUser")
        static let UnmuteChannel = localizedString(forKey: "UnmuteChannel")
        static let MuteButton = localizedString(forKey: "MuteButton")
        static let UnmuteButton = localizedString(forKey: "UnmuteButton")
    }

    struct MutePopup {
        static let EightHour = localizedString(forKey: "EightHour")
        static let OneWeek = localizedString(forKey: "OneWeek")
        static let OneYear = localizedString(forKey: "OneYear")
    }
}
