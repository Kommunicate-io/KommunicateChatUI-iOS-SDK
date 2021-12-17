//
//
// ALKCustomEvent.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
public class ALKCustomEvent {
    public var eventName: ALKCustomEventMap
    public weak var callback: ALKCustomEventCallback?

    public init (eventName: ALKCustomEventMap,eventCallBack: ALKCustomEventCallback?){
        self.eventName = eventName
        self.callback = eventCallBack
    }
}
