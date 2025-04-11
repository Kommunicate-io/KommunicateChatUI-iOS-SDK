//
//
// ALKCustomEventCallback.swift
// KommunicateChatUI-iOS-SDK
//
// Created by ___Sathyan Elangovan___ on 09/12/21

import Foundation
import KommunicateCore_iOS_SDK

public protocol ALKCustomEventCallback: AnyObject {
    func messageSent(message: ALMessage)
    func messageReceived(message: ALMessage)
    func conversationResolved(conversationId: String)
    func conversationRestarted(conversationId: String)
    func onBackButtonClick(isConversationOpened: Bool)
    func faqClicked(url: String)
    func conversationCreated(conversationId: String)
    func ratingSubmitted(conversationId: String, rating: Int, comment: String)
    func richMessageClicked(conversationId: String, action: Any, type: String)
    func conversationInfoClicked()
    func currentOpenedConversation(conversationId: String)
    func attachmentOptionClicked(attachemntType: String)
    func voiceButtonClicked(currentState: KMVoiceRecordingState)
    func locationButtonClicked()
    func rateConversationEmotionsClicked(rating: Int)
    func cameraButtonClicked()
    func videoButtonClicked()
}

// Voice Recording Sate
public enum KMVoiceRecordingState: String {
    case started = "Voice Recording Started"
    case stopped = "Voice Recording Stopped"
    case cancelled = "Voice Recording Cancelled"
}
