//
//  SystemMessage.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Foundation

//handle all in app's display messages
struct SystemMessage {

    struct Camera {
        static let CamNotAvailable = "Camera is not available"
        static let GalleryAvailable = "Gallery is not available"
        static let PictureCropped = "Image cropped"
        static let PictureReset = "Image reset"
        static let PleaseAllowCamera = "Please change Settings to allow to access your camera"
    }
    
    struct Microphone {
        static let MicNotAvailable = "Microphone is not available"
        static let PleaseAllowMic = "Please change Settings to allow sound recording"
        static let SlideToCancel = "Slide to cancel"
        static let Recording = "Recording"
    }
    
    struct Map {
        static let NoGPS = "Cannot detects current location, please turn on GPS"
        static let MapIsLoading = "Map is loading, please wait"
        static let AllowPermission = "Please change Settings to allow GPS"
    }
    
    struct Information {
        static let FriendAdded = "Friend Added"
        static let FriendRemoved = "Friend Removed"
        static let AppName = ""
        static let ChatHere = "Type something..."
        static let NotPartOfGroup = "You are not part of this group"
    }
    
    struct Update {
        static let CheckRequiredField = "Please input display name and profile image"
        static let UpdateMood = "Update Mood success"
        static let UpdateProfileName = "Update Profile success"
        static let Failed = "Failed to update"
    }
    
    struct Warning {
        static let NoEmail = "Please enter email address"
        static let InvalidEmail = "Invalid email address"
        static let FillInAllFields = "Please fill-in all fields"
        static let FillInPassword = "Please fill-in password"
        static let PasswordNotMatched = "Password does not match the confirm password"
        static let CamNotAvaiable = "Unable to start your camera"
        static let Cancelled = "Cancelled"
        static let PleaseTryAgain = "Connection failed. Please retry again"
        static let FetchFail = "Fetch data failed. Please retry again"
        static let OperationFail = "Operation could not be completed. Please retry again"
        static let DeleteSingleConversation = "Are you sure you want to remove the chat with"
        static let LeaveGroupConoversation = "Are you sure you want to leave the group"
        static let DeleteGroupConversation = "Are you sure you want to remove the group"
        static let DeleteContactWith = "Are you sure you want to remove"
        static let DownloadOriginalImageFail = "Fail to download the original image"
        static let ImageBeingUploaded = "The image is being uploaded"
        static let SignOut = "Are you sure you want to sign out?"
    }
    
    struct ButtonName {
        static let SignOut = "Sign out"
        static let Retry = "Retry"
        static let Remove = "Remove"
        static let Leave = "Leave"
        static let Cancel = "Cancel"
        static let Discard = "Discard"
    }
    
    struct NoData {
        static let NoName = "No Name"
    }
    
    struct UIError {
        static let unspecifiedLocation = "Unspecified Location"
    }
    
    struct PhotoAlbum {
        static let Success  = "Photo saved"
        static let Fail     = "Save failed"
        static let SuccessTitle = "Done"
        static let FailureTitle = "Error"
        static let Ok = "Ok"
    }

    struct Message {
        static let isTypingForRTL = "typing is "
    }
}
