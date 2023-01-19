//
//
// ALKCustomEventCallback.swift
// KommunicateChatUI-iOS-SDK
//
// Created by ___Sathyan Elangovan___ on 09/12/21

import Foundation
import KommunicateCore_iOS_SDK

public protocol ALKCustomEventCallback: AnyObject {
    func messageSent(message: ALMessage)
    func messageReceived(message: ALMessage)
    func conversationRestarted(converstionId: String)
    func conversationBackPressed()
    func conversationListBackPressed()
    func faqClicked(url: String)
    func conversationCreated(conversationId: String)
    func ratingSubmitted(conversationId: String,rating:Int, comment: String)
    func richMessageClicked(conversationId:String,action:[String:Any], type:String)
}
