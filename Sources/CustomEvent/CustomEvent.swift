//
//
// ALKCustomEventMap.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
public enum CustomEvent: String {
    case messageSend = "ON_MESSAGE_SEND"
    case faqClick = "ON_FAQ_CLICK"
    case notificationClick = "ON_NOTIFICATION_CLICK"
    case newConversation = "ON_START_NEW_CONVERSATION_CLICK"
    case attachmentClick = "ON_ATTACHMENT_ICON_CLICK"
    case voiceClick = "ON_VOICE_ICON_CLICK"
    case locationClick = "ON_LOCATION_ICON_CLICK"
    case rateConversationClick = "ON_RATE_CONVERSATION_CLICK"
    case rateConversationEmotionsClick = "ON_RATE_CONVERSATION_EMOTIONS_CLICK"
    case submitRatingClick = "ON_SUBMIT_RATING_CLICK"
    case restartConversationClick = "ON_RESTART_CONVERSATION_CLICK"
    case richMessageClick = "ON_RICH_MESSAGE_CLICK"
    case resolveConversation = "ON_CONVERSATION_RESOLVE"
}
