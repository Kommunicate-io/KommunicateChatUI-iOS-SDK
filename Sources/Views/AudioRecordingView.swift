//
//  AudioRecordingView.swift
//  Applozic
//
//  Created by Shivam Pokhriyal on 17/08/18.
//

import Foundation

import AVFoundation

public protocol ALKAudioRecorderViewProtocol{
    func cancelAudioRecording()
}

open class ALKAudioRecorderView: UIView {
    
    private var isTimerStart:Bool = false
    private var timer = Timer()
    private var counter = 0
    private var previousGestureLocation: CGFloat = 0.0
    private var slideToCancelStartLocation: CGFloat = 0.0
    private var recordingViewStartLocation: CGFloat = 0.0
    
    private var delegate: ALKAudioRecorderViewProtocol!
    
    lazy var slideToCancel: UILabel = {
        let label = self.commonLabel()
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.textColor = UIColor(red: 140, green: 137, blue: 137)
        return label
    }()
    
    let redDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.backgroundColor = UIColor(red: 255, green: 14, blue: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var recordingLabel: UILabel = {
        let label = self.commonLabel()
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColor(red: 255, green: 14, blue: 0)
        return label
    }()
    
    lazy var recordingValue: UILabel = {
        let label = self.commonLabel()
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
        label.textColor = UIColor(red: 0, green: 0, blue: 0)
        label.text = "00:00"
        return label
    }()
    
    lazy var recordingView: UIStackView = {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [self.recordingLabel, self.recordingValue])
        stackView.alignment = UIStackViewAlignment.fill
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.distribution = UIStackViewDistribution.equalSpacing
        stackView.spacing = 2.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func commonLabel() -> UILabel{
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.alpha = 0.0
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }
    
    func setAudioRecViewDelegate(recorderDelegate:ALKAudioRecorderViewProtocol) {
        delegate = recorderDelegate
    }
    
    func animateView(){
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.slideToCancel.alpha = 1.0
            self.recordingLabel.alpha = 1.0
            self.recordingValue.alpha = 1.0
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false;
        setupUI()
        layer.cornerRadius = 12
        animateView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        self.backgroundColor = UIColor.color(.none)
        addSubview(redDot)
        addSubview(slideToCancel)
        addSubview(recordingView)
        
        redDot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        redDot.heightAnchor.constraint(equalToConstant: 8).isActive = true
        redDot.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        redDot.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -5).isActive = true
        
        recordingView.leadingAnchor.constraint(equalTo: redDot.leadingAnchor, constant: 10).isActive = true
        recordingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        slideToCancel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100).isActive = true
        slideToCancel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc public func userDidStartRecording(){
        isTimerStart = true
        counter = 0

        slideToCancel.text = NSLocalizedString("SlideToCancel", value: SystemMessage.Microphone.SlideToCancel, comment: "")
        recordingLabel.text = NSLocalizedString("Recording", value: SystemMessage.Microphone.Recording, comment: "")
        recordingValue.text = "00:00"
        previousGestureLocation = 0.0
        slideToCancelStartLocation = slideToCancel.frame.origin.x - slideToCancel.intrinsicContentSize.width
        recordingViewStartLocation = recordingView.frame.origin.x + recordingLabel.intrinsicContentSize.width + 10.0
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc public func userDidStopRecording(){
        slideToCancel.text = nil
        recordingLabel.text = nil
        recordingValue.text = nil
        stopTimer()
    }
    
    @objc public func moveView(location: CGPoint){
        let newPos = slideToCancel.frame.origin.x + (location.x - previousGestureLocation)
        if newPos > slideToCancelStartLocation{
            return
        }
        if slideToCancel.frame.origin.x <= recordingViewStartLocation{
            recordingView.frame.origin.x = recordingView.frame.origin.x + (location.x - previousGestureLocation)
            redDot.frame.origin.x = redDot.frame.origin.x + (location.x - previousGestureLocation)
            if recordingView.frame.origin.x <= 0.0{
                delegate.cancelAudioRecording()
            }
        }
        slideToCancel.frame.origin.x = newPos
        previousGestureLocation = location.x
    }
    
    private func stopTimer() {
        if isTimerStart == true
        {
            isTimerStart = false
            timer.invalidate()
        }
    }
    
    @objc private func updateCounter() {
        counter += 1
        
        //min
        let min = (counter / 60) % 60
        let sec = (counter % 60)
        var minStr = String(min)
        var secStr = String(sec)
        if sec < 10 {secStr = "0\(secStr)"}
        if min < 10 {minStr = "0\(minStr)"}
        self.recordingValue.text = "\(minStr):\(secStr)"
    }
}
