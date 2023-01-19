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
    public func publish(triggeredEvent: CustomEvent, data: [String: Any]?) {
        guard let delegate = delegate,
              subscribedEvents.contains(triggeredEvent) else { return }
              
        switch triggeredEvent {
            case .faqClick:
                guard let data = data,
                      let url = data["faqUrl"] as? String else { return }
                delegate.faqClicked(url: url)
            case .messageSend:
                guard let data = data,
                      let message = data["message"] as? ALMessage else {return}
                delegate.messageSent(message: message)
            case .newConversation:
                guard let data = data,
                      let conversationId = data["conversationId"] as? String else { return }
                delegate.conversationCreated(conversationId: conversationId)
            case .submitRatingClick:
                guard let data = data,
                      let conversationId = data["conversationId"] as? String,
                      let rating = data["rating"] as? Int,
                      let comment = data["comment"] as? String  else { return }
                delegate.ratingSubmitted(conversationId: conversationId, rating: rating, comment: comment)
            case .restartConversationClick:
                guard let data = data,
                      let conversationId = data["conversationId"] as? String else { return }
                delegate.conversationRestarted(converstionId: conversationId)
            case .richMessageClick:
                guard let data = data,
                      let conversationId = data["conversationId"] as? String,
                      let action = data["action"] as? [String:Any],
                      let type = data["type"] as? String else { return }
                delegate.richMessageClicked(conversationId: conversationId, action: action, type: type)
            case .conversationBackPress:
                delegate.conversationBackPressed()
            case .conversationListBackPress:
                delegate.conversationListBackPressed()
            case .messageReceive:
                guard let data = data,
                      let messages = data["messageList"] as? [ALMessage] else {return}
                for message in messages {
                    delegate.messageReceived(message: message)
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

    var subscribedEvents = [CustomEvent]()
    /**
         This method is to subscribe the events.
        - Parameters:
        - eventsList : list of event
        - eventDelegate : delegate to send the subscribed event data
     */
    public func setSubscribedEvents(eventsList: [CustomEvent], eventDelegate: ALKCustomEventCallback) {
        delegate = eventDelegate
        subscribedEvents.removeAll()
        subscribedEvents = eventsList
    }
}
