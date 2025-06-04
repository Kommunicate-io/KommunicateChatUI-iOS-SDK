//
//
// ALKCustomEventHandler.swift
// KommunicateChatUI-iOS-SDK
//
// Created by ___Sathyan Elangovan___ on 09/12/21

import Foundation
import KommunicateCore_iOS_SDK

public class ALKCustomEventHandler {
    public static let shared = ALKCustomEventHandler()
    weak var delegate: ALKCustomEventCallback?

    /**
         This method is to publish the triggered event data if that particular event is subscribed
        - Parameters:
        - triggeredEvent : event type
        - data : data of triggered event
     */
    public func publish(triggeredEvent: KMCustomEvent, data: [String: Any]?) {
        guard let delegate = delegate,
              subscribedEvents.contains(triggeredEvent) else { return }

        switch triggeredEvent {
        case .faqClick:
            if let url = data?["faqUrl"] as? URL {
                delegate.faqClicked(url: url.absoluteString)
            } else if let urlString = data?["faqUrl"] as? String,
                      let url = URL(string: urlString) {
                delegate.faqClicked(url: url.absoluteString)
            }

        case .messageSend:
            if let message = data?["message"] as? KMCoreMessage {
                delegate.messageSent(message: message)
            }

        case .newConversation:
            if let conversationId = data?["conversationId"] as? String {
                delegate.conversationCreated(conversationId: conversationId)
            }

        case .submitRatingClick:
            if let conversationId = data?["conversationId"] as? Int,
                let rating = data?["rating"] as? Int,
                let comment = data?["comment"] as? String {
                delegate.ratingSubmitted(conversationId: String(conversationId), rating: rating, comment: comment)
            }

        case .resolveConversation:
            if let conversationId = data?["conversationId"] as? String {
                delegate.conversationResolved(conversationId: conversationId)
            }

        case .restartConversationClick:
            if let conversationId = data?["conversationId"] as? Int {
                delegate.conversationRestarted(conversationId: String(conversationId))
            }

        case .richMessageClick:
            let conversationId = data?["conversationId"] as? String ?? ""
            let action = data?["action"] ?? "Action Not Present"
            let type = data?["type"] as? String ?? ""
            delegate.richMessageClicked(conversationId: conversationId, action: action, type: type)

        case .conversationBackPress:
            delegate.onBackButtonClick(isConversationOpened: true)

        case .conversationListBackPress:
            delegate.onBackButtonClick(isConversationOpened: false)

        case .messageReceive:
            if let messages = data?["messageList"] as? [KMCoreMessage] {
                messages.forEach { delegate.messageReceived(message: $0) }
            }

        case .conversationInfoClick:
            delegate.conversationInfoClicked()
        
        case .attachmentOptionClicked:
            if let attachmentType = data?["attachmentType"] as? String {
                delegate.attachmentOptionClicked(attachemntType: attachmentType)
            }
            
        case .voiceButtonClicked:
            if let currentState = data?["currentState"] as? KMVoiceRecordingState {
                delegate.voiceButtonClicked(currentState: currentState)
            }
            
        case .locationButtonClicked:
            delegate.locationButtonClicked()
            
        case .rateConversationEmotionsClicked:
            if let rating = data?["rating"] as? Int {
                delegate.rateConversationEmotionsClicked(rating: rating)
            }
            
        case .cameraButtonClicked:
            delegate.cameraButtonClicked()
            
        case .videoButtonClicked:
            delegate.videoButtonClicked()
            
        case .currentOpenedConversation:
            if let conversationId = data?["conversationId"] as? Int {
                delegate.currentOpenedConversation(conversationId: String(conversationId))
            }
        }
    }

    // CSAT Values
    public enum CSATRating: String {
        case poor = "CSAT Rate: Poor"
        case average = "CSAT Rate: Average"
        case great = "CSAT Rate: Great"
    }

    // Attach types
    public enum AttachmentType: String {
        case contact = "Contact"
        case camera = "Camera"
        case video = "Video"
        case gallery = "Gallery"
        case document = "Document"
    }

    var subscribedEvents = [KMCustomEvent]()
    /**
         This method is to subscribe the events.
        - Parameters:
        - eventsList : list of event
        - eventDelegate : delegate to send the subscribed event data
     */
    public func setSubscribedEvents(eventsList: [KMCustomEvent], eventDelegate: ALKCustomEventCallback) {
        delegate = eventDelegate
        subscribedEvents.removeAll()
        subscribedEvents = eventsList
    }
    
    /**
     This method is to unsubscribe events
     */
    public func unsubscribeEvents() {
        subscribedEvents.removeAll()
    }
    
    /// This method is used to retrieve a list of all available events.
    public func availableEvents() -> [KMCustomEvent] {
        return KMCustomEvent.allEvents
    }
}
