//
//
// ALKCustomEvent.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
open class ALKCustomEvent {
    public var eventName: String
    public var data: ALKCustomEventData?
    public var callback: ALKCustomEventCallback?

    public init (eventName: String, eventData: ALKCustomEventData?,eventCallBack: ALKCustomEventCallback?){
        self.eventName = eventName
        self.data = eventData
        self.callback = eventCallBack
    }
}
