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
class KMTextToSpeech : NSObject, AVSpeechSynthesizerDelegate  {
    let synthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer()
    var index = 0
    var speechStarted = false
   
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    public static let shared = KMTextToSpeech()
    var messageModels : [ALMessage] = []
   
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        index += 1
        guard index < messageModels.count else {return speechStarted = false}
        speakCurrentMessage()
    }
    
    /**
         This method is to trigger the specch from message
        - Parameters:
        - triggeredEvent : event type
        - data : data of triggered event
     */
    func speakCurrentMessage(){
         guard index < messageModels.count else {return speechStarted = false}
         let utterance = AVSpeechUtterance(string: messageModels[index].message ?? "")
         synthesizer.speak(utterance)
    }
    
    /**
    This method is to add message to existing list for the specch
   - Parameters:
   - list : [ALMessage]
     */
    func addMessagesToSpeech(_ list: [ALMessage]) {
        messageModels += list
        guard speechStarted == false, index < messageModels.count else{return}
        speakCurrentMessage()
        speechStarted = true
    }
    
    // This method is to reset the message queue for the Synthesizer
    func resetSynthesizer() {
        if synthesizer.isSpeaking || speechStarted {
            synthesizer.stopSpeaking(at: .immediate)
        }
        messageModels.removeAll()
        index = 0
    }
}
