//
// KMCustomEvent.swift
// KommunicateChatUI-iOS-SDK
// Created by Sathyan Elangovan on 09/12/21.

import Foundation

public enum KMCustomEvent: String, CaseIterable {
    case messageSend = "ON_MESSAGE_SEND"
    case faqClick = "ON_FAQ_CLICK"
    case newConversation = "ON_START_NEW_CONVERSATION_CLICK"
    case submitRatingClick = "ON_SUBMIT_RATING_CLICK"
    case resolveConversation = "ON_CONVERSATION_RESOLVE"
    case restartConversationClick = "ON_RESTART_CONVERSATION_CLICK"
    case richMessageClick = "ON_RICH_MESSAGE_CLICK"
    case conversationBackPress = "ON_CONVERSATION_BACK_CLICK"
    case conversationListBackPress = "ON_CONVERSATION_LIST_BACK_CLICK"
    case messageReceive = "ON_MESSAGE_RECEIVE"
    case conversationInfoClick = "ON_CONVERSATION_INFO_CLICK"
    case attachmentOptionClicked = "ON_ATTACHEMENT_OPTION_CLICK"
    case voiceButtonClicked = "ON_VOICE_BUTTON_CLICK"
    case locationButtonClicked = "ON_LOCATION_BUTTON_CLICK"
    case rateConversationEmotionsClicked = "ON_RATE_CONVERSATION_EMOTIONS_CLICK"
    case cameraButtonClicked = "ON_CAMERA_BUTTON_CLICK"
    case videoButtonClicked = "ON_VIDEO_BUTTON_CLICK"
    case currentOpenedConversation = "ON_CURRENT_OPENED_CONVERSATION"
    
    public static var allEvents: [KMCustomEvent] {
        return Array(self.allCases)
    }
}
