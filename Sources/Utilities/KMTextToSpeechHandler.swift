//
//  KMTextToSpeechHandler.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 29/07/22.
//


import Foundation
import AVFoundation

class KMTextToSpeechHandler : NSObject, AVSpeechSynthesizerDelegate  {
    let synthesizer = AVSpeechSynthesizer()
    var index = 0
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    let list = ["Hello World!","Does he have luxury cars ?","Yes , He has many luxury cars"," Is he rich ?","Does he have driving licence? ","Does he have children/kids ?","Does he have business in Chennai ? "]
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        index += 1
        if index < list.count {
            speakCurrentWord()
        }
    }
    
    func speakCurrentWord(){
        let utterance = AVSpeechUtterance(string: list[index])
        synthesizer.speak(utterance)
    }

}
