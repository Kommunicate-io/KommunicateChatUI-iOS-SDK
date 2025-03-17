//
//  KMTextToSpeechHandler.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 29/07/22.
//

import Foundation
import AVFoundation
import KommunicateCore_iOS_SDK

// To handle Text To Speech in the conversation
class KMTextToSpeech: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private var messageToBeProcessed = 0
    private var speechStarted = false
   
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    public static let shared = KMTextToSpeech()
    var messageQueue: [ALMessage] = []
   
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        messageToBeProcessed += 1
        guard messageToBeProcessed < messageQueue.count else {return speechStarted = false}
        speakCurrentMessage()
    }
    
    /**
         This method is to trigger the speech from message
        - Parameters:
        - triggeredEvent : event type
        - data : data of triggered event
     */
    func speakCurrentMessage() {
         guard messageToBeProcessed < messageQueue.count else {return speechStarted = false}
         let utterance = AVSpeechUtterance(string: messageQueue[messageToBeProcessed].message ?? "")
         synthesizer.speak(utterance)
    }
    
    /**
    This method is to add message to existing list for the specch
   - Parameters:
   - list : [ALMessage]
     */
    func addMessagesToSpeech(_ list: [ALMessage]) {
        for messagge in list {
            if !messageQueue.contains(where: { $0 === messagge }) {
                messageQueue.append(messagge)
            }
        }
        guard speechStarted == false, messageToBeProcessed < messageQueue.count else {return}
        speakCurrentMessage()
        speechStarted = true
    }
    
    // This method is to reset the message queue for the Synthesizer
    func resetSynthesizer() {
        if synthesizer.isSpeaking || speechStarted {
            synthesizer.stopSpeaking(at: .immediate)
        }
        messageQueue.removeAll()
        messageToBeProcessed = 0
    }
}
