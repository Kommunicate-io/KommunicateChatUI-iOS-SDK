//
//  SoundRecordingView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

import AVFoundation

public protocol ALKSoundRecorderProtocol: class {
    func finishRecordingAudio(soundData:NSData)
    func startRecordingAudio()
    func cancelRecordingAudio()
    func permissionNotGrant()
}

open class ALKSoundRecorderBtn: UIButton {
    
    private var isTimerStart:Bool = false
    private var timer = Timer()
    private var counter = 0
    private var delegate:ALKSoundRecorderProtocol!
    
    //aduio session
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    fileprivate var audioFilename:URL!
    private var audioPlayer: AVAudioPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect,recorderDelegate:ALKSoundRecorderProtocol) {
        super.init(frame: frame)
        delegate = recorderDelegate
        setupRecordingSession()
    }
    
    func setSoundRecDelegate(recorderDelegate:ALKSoundRecorderProtocol) {
        delegate = recorderDelegate
        setupRecordingSession()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Create UI
    private func createUI()
    {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapAudioRecord))
        tapGesture.numberOfTapsRequired = 1
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(startAudioRecordGesture(sender:)))
        
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(longGesture)
        
        layer.cornerRadius = 12
        displayDefaultText()
    }
    
    private func displayDefaultText() {
        isTimerStart = false
        backgroundColor = UIColor.background(.grayEF)
        setTextColor(color: UIColor.text(Color.Text.main), forState: .normal)
        setFont(font:UIFont.font(.normal(size: 14)))
        let holdToTalkMessage = NSLocalizedString("HoldToTalkMessage", value: "Hold to Talk / Tap to Type", comment: "")
        setTitle(holdToTalkMessage, for: .normal)
        setTitle(holdToTalkMessage, for: .highlighted)
    }
    
    private func displayDefaultRecordingText() {
        backgroundColor = UIColor.mainRed()
        setFont(font:UIFont.font(.normal(size: 14)))
        setTextColor(color:.white, forState: .normal)
        setTextColor(color:.white, forState: .highlighted)
        let recordingMessage = NSLocalizedString("RecordingMessage", value: "Recording...00:00:00", comment: "")
        setTitle(recordingMessage, for: .normal)
        setTitle(recordingMessage, for: .highlighted)
    }
    
    private func setupRecordingSession()
    {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {[weak self] allowed in
                DispatchQueue.main.async {
                    guard let weakSelf = self else {return}
                    if allowed {
                        weakSelf.createUI()
                    } else {
                        weakSelf.removeFromSuperview()
                    }
                }
            }
        } catch {
            self.removeFromSuperview()
        }
    }
    
    //MARK: - Function
    private func checkMicrophonePermission() -> Bool {
        
        let soundSession = AVAudioSession.sharedInstance()
        let permissionStatus = soundSession.recordPermission()
        var isAllow = false
        
        switch (permissionStatus) {
        case AVAudioSessionRecordPermission.undetermined:
            soundSession.requestRecordPermission({ (isGrant) in
                if (isGrant) {
                    isAllow = true
                }
                else {
                    isAllow = false
                }
            })
            break
        case AVAudioSessionRecordPermission.denied:
            // direct to settings...
            isAllow = false
            break;
        case AVAudioSessionRecordPermission.granted:
            // mic access ok...
            isAllow = true
            break;
        }
        
        return isAllow
    }
    
    @objc func startAudioRecordGesture(sender : UIGestureRecognizer){
        let point = sender.location(in: self)
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        if sender.state == .ended {
            stopAudioRecord()
        }
        else if sender.state == .changed {
            
            if point.x < 0 || point.x > width || point.y < 0 || point.y > height {
                cancelAudioRecord()
            }
        }
        else if sender.state == .began {
            
            if delegate != nil {
                delegate.startRecordingAudio()
            }
            
            if checkMicrophonePermission() == false {
                if delegate != nil {
                    delegate.permissionNotGrant()
                }
            } else {
                
                if point.x > 0 || point.x < width || point.y > 0 || point.y < height {
                    startAudioRecord()
                }
            }
            
        }
    }
    
    @objc fileprivate func startAudioRecord()
    {
        isTimerStart = true
        counter = 0
        displayDefaultRecordingText()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(ALKSoundRecorderBtn.updateCounter), userInfo: nil, repeats: true)
        
        audioFilename = URL(fileURLWithPath: NSTemporaryDirectory().appending("tempRecording.m4a"))
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            stopAudioRecord()
        }
    }
    
    @objc fileprivate func singleTapAudioRecord() {
        cancelAudioRecord()
        if delegate != nil {
            delegate.cancelRecordingAudio()
        }
        
    }
    
    @objc func cancelAudioRecord() {
        if isTimerStart == true
        {
            isTimerStart = false
            timer.invalidate()
            
            audioRecorder.stop()
            audioRecorder = nil
            
            displayDefaultText()
        }
    }
    
    @objc fileprivate func stopAudioRecord()
    {
        if isTimerStart == true
        {
            isTimerStart = false
            timer.invalidate()
            displayDefaultText()
            
            audioRecorder.stop()
            audioRecorder = nil
            
            //play back?
            
            if audioFilename.isFileURL
            {
                guard let soundData = NSData(contentsOf: audioFilename) else {return}
                delegate.finishRecordingAudio(soundData: soundData)
            }
        }
    }
    
    private func playSound(url:URL) {
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = audioPlayer else { return }
            
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error {
        }
    }
    
    @objc fileprivate func updateCounter() {
        counter += 1
        
        //min
        let min = (counter / 60) % 60
        let sec = (counter % 60)
        var minStr = String(min)
        var secStr = String(sec)
        if sec < 10 {secStr = "0\(secStr)"}
        if min < 10 {minStr = "0\(minStr)"}
        let recordingMessage = NSLocalizedString("RecordingMessage", value: "Recording...00:", comment: "")
        setTitle("\(recordingMessage)\(minStr):\(secStr)", for: .normal)
        setTitle("\(recordingMessage)\(minStr):\(secStr)", for: .highlighted)
    }
}

extension ALKSoundRecorderBtn: AVAudioRecorderDelegate
{
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopAudioRecord()
        }
    }
}
