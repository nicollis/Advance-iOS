//
//  Talker.swift
//  NerdCam
//
//  Created by Michael Ward on 9/19/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import Foundation
import AVFoundation

class Talker {
    
    private let synth = AVSpeechSynthesizer()
    
    private let voice: AVSpeechSynthesisVoice = {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let englishVoices = voices.filter { $0.language.hasPrefix("en") }
        let voice = englishVoices.first ?? voices.first!
        return voice
    }()
    
    func say(_ words: String) {
        let utterance = AVSpeechUtterance(string: words)
        utterance.voice = voice
        synth.speak(utterance)
    }
    
}
