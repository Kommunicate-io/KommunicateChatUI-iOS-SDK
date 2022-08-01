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
class KMTextToSpeechHandler : NSObject, AVSpeechSynthesizerDelegate  {
    let synthesizer : AVSpeechSynthesizer = AVSpeechSynthesizer()
    var index = 0
   
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func clearMessageList() {
        messageModels.removeAll()
        index = 0
    }
    
    public static let shared = KMTextToSpeechHandler()
    var messageModels : [ALMessage] = []
   
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        index += 1
        guard index < messageModels.count else {return}
        speakCurrentMessage()
    }
    
     func speakCurrentMessage(){
         guard index < messageModels.count else {return}
         let utterance = AVSpeechUtterance(string: messageModels[index].message ?? "")
         synthesizer.speak(utterance)
    }
    
     func addMessagesToSpeech(_ list: [ALMessage]) {
         for item in list {
             if !messageModels.contains(item) {
                 messageModels.append(item)
             }
         }
         guard !synthesizer.isSpeaking else{return}
         speakCurrentMessage()
    }

}
