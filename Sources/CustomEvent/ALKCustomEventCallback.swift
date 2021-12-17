//
//
// ALKCustomEventCallback.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
public protocol ALKCustomEventCallback: AnyObject {
    func eventTriggered(eventType: ALKCustomEventMap,data: [String: Any]?)
}
