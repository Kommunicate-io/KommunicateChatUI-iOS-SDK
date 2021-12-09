//
//
// ALKCustomEventHandler.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
open class ALKCustomEventHandler {
    public static func trackEvent(trackingevent: ALKCustomEvent, value: String?) {
        guard let event = subscribedEvents[trackingevent.eventName] else {
                print("Event is not subscribed")
                return
            }
            if trackingevent.eventName == ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_EMOTIONS_CLICK{
                switch value {
                case "1":
                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)
                case "5":
                    trackingevent.data!.updateLabel(updatedLabel:CSAT_AVERAGE)
                case "10":
                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)
                default:
                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)

                }
                trackingevent.data?.eventValue = value
            }
            if let callback = event.callback {
                callback.eventTriggered(eventType:event.eventName ,data: trackingevent.data!)
            }

    }
    public static let eventCategory:String = "Kommunicate"
    public static let actionClick = "Click"
    public static let actionSent = "Sent"
    public static let actionOpen = "Open"
    public static let actionClose = "Close"
    public static let actionStart = "Start"
    public static let actionStarted = "Started"
    public static let actionRestart = "Restart"
    public static let actionRichClick = "Rich message Click"
    public static let actionSubmit = "Submit"
    public static let actionRate = "Rate"
    public static let actionStartNew = "Start New"
    // VALUES
    public static  let GALLERY_SECTION = "GALLERY"
    public static  let VIDEO_SECTION = "VIDEO"
    public static  let CAMERA_SECTION = "CAMERA"
    public static  let DOCUMENT_SECTION = "DOCUMENT"
    public static  let CONTACT_SECTION = "CONTACT"
    // CAST VALUES
    public static let CSAT_POOR = "CSAT Rate Poor"
    public static let CSAT_AVERAGE = "CSAT Rate Average"
    public static let CSAT_GREAT = "CSAT Rate Great"
   // labels
//    static let LABEL_ATTACHMEN

    public static let ON_ATTACHMENT_ICON_CLICK = ALKCustomEvent(eventName:ALKCustomEventMap.EVENT_ON_ATTACHMENT_ICON_CLICK ,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Attachment"),eventCallBack: nil)

    public static let ON_LOCATION_ICON_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_LOCATION_ICON_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Location"),eventCallBack: nil)
    public static let ON_MESSAGE_SEND = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_MESSAGE_SEND,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionSent, eventLabel: "Message"), eventCallBack: nil)
//
    public static let ON_FAQ_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_FAQ_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "FAQ Menu"),eventCallBack: nil)
    public static let ON_GREETING_MESSAGE_NOTIFICATION_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_GREETING_MESSAGE_NOTIFICATION_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Greeting"),eventCallBack: nil)
    public static let ON_NOTIFICATION_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_NOTIFICATION_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Notification"),eventCallBack: nil)
    public static let ON_RESOLVE_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RESOLVE_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Show Resolve"),eventCallBack: nil)
    public static let ON_START_NEW_CONVERSATION_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_START_NEW_CONVERSATION_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionStartNew, eventLabel: "Conversation Start"),eventCallBack: nil)
//    static let ON_ATTACHMENT_ICON_CLICK = KMCustomEvent(eventName: Kommunicate.EVENT_ON_ATTACHMENT_ICON_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Attachment"),eventCallBack: nil)
    public static let ON_VOICE_ICON_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_VOICE_ICON_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClick, eventLabel: "Voice Input"),eventCallBack: nil)
    public static let ON_RATE_CONVERSATION_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionStarted, eventLabel: "CSAT Start"),eventCallBack: nil)
    public static var ON_RATE_CONVERSATION_EMOTIONS_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_EMOTIONS_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionRate, eventLabel: "CSAT Rate Poor"),eventCallBack: nil)
    public static let ON_SUBMIT_RATING_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_SUBMIT_RATING_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionSubmit, eventLabel: "CSAT Submit"),eventCallBack: nil)
    public static let ON_CHAT_CLOSE_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_CHAT_CLOSE_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionClose, eventLabel: "Chat Widget Close"),eventCallBack: nil)
    public static let ON_CHAT_OPEN_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_CHAT_OPEN_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionOpen, eventLabel: "Chat Widget Open"),eventCallBack: nil)
    public static let ON_RESTART_CONVERSATION_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RESTART_CONVERSATION_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionRestart, eventLabel: "Conversation Restart"),eventCallBack: nil)
    public static var ON_RICH_MESSAGE_CLICK = ALKCustomEvent(eventName: ALKCustomEventMap.EVENT_ON_RICH_MESSAGE_CLICK,eventData: ALKCustomEventData(eventCategory: eventCategory, eventAction: actionRichClick, eventLabel: "Chat Widget Close"),eventCallBack: nil)
    public static var subscribedEvents = [String:ALKCustomEvent]()

    public static func setSubscribedEvents(eventsList: [ALKCustomEvent]){
        if !eventsList.isEmpty {
            for event in eventsList {
                subscribedEvents[event.eventName] = event
            }
        } else {
            print("Subscribe Event List is Nil")
        }
    }
}
