//
//
// ALKCustomEventHandler.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
open class ALKCustomEventHandler {
//     public static func trackEvent(trackingevent: ALKCustomEvent, value: String?) {
//        guard let event = subscribedEvents[trackingevent.eventName.rawValue] else {
//                print("Event is not subscribed")
//                return
//            }
//            if trackingevent.eventName == ALKCustomEventMap.EVENT_ON_RATE_CONVERSATION_EMOTIONS_CLICK{
//                switch value {
//                case "1":
//                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)
//                case "5":
//                    trackingevent.data!.updateLabel(updatedLabel:CSAT_AVERAGE)
//                case "10":
//                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)
//                default:
//                    trackingevent.data!.updateLabel(updatedLabel:CSAT_POOR)
//
//                }
//                trackingevent.data?.eventValue = value
//            }
//            if let callback = event.callback {
//                callback.eventTriggered(eventType:event.eventName.rawValue ,data: trackingevent.data!)
//            }s
//
//    }
    public static func publish(triggeredEvent: ALKCustomEventMap, data:[String: Any]?) {
        guard let event = subscribedEvents[triggeredEvent] else {
                print("Event is not subscribed")
                return
            }
        if let callback = event.callback {
            callback.eventTriggered(eventName:triggeredEvent, data: data)
        }
    }
    // CAST VALUES
    public enum CSATRATING: String {
        case  POOR = "CSAT Rate: Poor"
        case  AVERAGE = "CSAT Rate: Average"
        case  GREAT = "CSAT Rate: Great"
    }
    // Attach types
    public enum ATTACHMENT_TYPE: String {
        case CONTACT = "Contact"
        case CAMERA = "Camera"
        case VIDEO = "Video"
        case GALLERY = "Gallery"
        case DOCUMENT = "Document"

    }
     static var subscribedEvents = [ALKCustomEventMap:ALKCustomEvent]()

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
