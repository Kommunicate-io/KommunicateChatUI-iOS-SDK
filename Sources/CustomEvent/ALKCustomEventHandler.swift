//
//
// ALKCustomEventHandler.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation

class ALKCustomEventHandler {
    public static let shared = ALKCustomEventHandler()
    weak var delegate: ALKCustomEventCallback?

    public func publish(triggeredEvent: CustomEvent, data:[String: Any]?) {
        if subscribedEvents.contains(triggeredEvent){
            delegate?.eventTriggered(eventName: triggeredEvent, data: data)
        }
    }
    // CSAT Values
    public enum CSATRating: String {
        case  poor = "CSAT Rate: Poor"
        case  average = "CSAT Rate: Average"
        case  great = "CSAT Rate: Great"
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

    public  func setSubscribedEvents(eventsList: [CustomEvent], eventDelegate:ALKCustomEventCallback){
        delegate = eventDelegate
        subscribedEvents.removeAll()
        subscribedEvents = eventsList
    }
}
