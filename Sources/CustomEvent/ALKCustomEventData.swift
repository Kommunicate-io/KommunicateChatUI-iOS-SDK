//
//
// ALKCustomEventData.swift
// ApplozicSwift
//
// Created by ___Sathyan Elangovan___ on 09/12/21
import Foundation
open class ALKCustomEventData: Decodable {
    var eventCategory: String
    var eventAction: String
    var eventLabel: String
    var eventValue: String?
    public init(eventCategory: String,eventAction: String, eventLabel: String ) {
        self.eventLabel = eventLabel
        self.eventCategory = eventCategory
        self.eventAction = eventAction
    }
    public func updateLabel(updatedLabel: String) {
        self.eventLabel = updatedLabel
    }
}
