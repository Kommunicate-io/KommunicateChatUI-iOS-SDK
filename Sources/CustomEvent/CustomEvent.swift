//
// CustomEvent.swift
// KommunicateChatUI-iOS-SDK
// Created by Sathyan Elangovan on 09/12/21.

import Foundation

public enum CustomEvent: String {
    case messageSend = "ON_MESSAGE_SEND"
    case faqClick = "ON_FAQ_CLICK"
    case newConversation = "ON_START_NEW_CONVERSATION_CLICK"
    case submitRatingClick = "ON_SUBMIT_RATING_CLICK"
    case restartConversationClick = "ON_RESTART_CONVERSATION_CLICK"
    case richMessageClick = "ON_RICH_MESSAGE_CLICK"
    case conversationBackPress = "ON_CONVERSATION_BACK_CLICK"
    case conversationListBackPress = "ON_CONVERSATION_LIST_BACK_CLICK"
    case messageReceive = "ON_MESSAGE_RECEIVE"
}
