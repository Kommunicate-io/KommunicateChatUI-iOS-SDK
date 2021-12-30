//
//
// ALKCustomEventHandler.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation

public class ALKCustomEventHandler {
    public static let shared = ALKCustomEventHandler()
    weak var delegate: ALKCustomEventCallback?

    /**
         This method is to publish the triggered event data if that particular event is subscribed
        - Parameters:
        - triggeredEvent : event type
        - data : data of triggered event
     */
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
    /**
         This method is to subscribe the events.
        - Parameters:
        - eventsList : list of event
        - eventDelegate : delegate to send the subscribed event data
     */
    public  func setSubscribedEvents(eventsList: [CustomEvent], eventDelegate:ALKCustomEventCallback){
        delegate = eventDelegate
        subscribedEvents.removeAll()
        subscribedEvents = eventsList
    }
}
