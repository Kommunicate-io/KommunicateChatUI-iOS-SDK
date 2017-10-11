//
//  ALKChatBar.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit


final class ALKChatBar: UIView {
    
    enum ButtonMode {
        case send
        case media
    }
    
    enum ActionType {
        case sendText(UIButton,String)
        case chatBarTextBeginEdit()
        case chatBarTextChange(UIButton)
        case sendPhoto(UIButton,UIImage)
        case sendVoice(NSData)
        case startVideoRecord()
        case startVoiceRecord()
        case showImagePicker()
        case showLocation()
        case noVoiceRecordPermission()
        case mic(UIButton)
        case more(UIButton)
    }
    
    var action: ((ActionType) -> ())?
    
    let soundRec: ALKSoundRecorderBtn = {
        let bt = ALKSoundRecorderBtn.init(frame: CGRect.init())
        bt.layer.masksToBounds = true
        return bt
    }()
    
    let textView: ALKChatBarTextView = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let tv = ALKChatBarTextView()
        tv.setBackgroundColor(color: .none)
//        tv.clipsToBounds = true
        tv.scrollsToTop = false
        tv.autocapitalizationType = .sentences
        tv.accessibilityIdentifier = "chatTextView"
        tv.typingAttributes = [NSParagraphStyleAttributeName: style, NSFontAttributeName: UIFont.font(.normal(size: 16.0))]
        return tv
    }()
    
    fileprivate let frameView: UIImageView = {
        
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
//        view.image = UIImage.init(named: "text_frame", in: Bundle.applozic, compatibleWith: nil)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate let grayView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate let placeHolder: UITextView = {
        
        let view = UITextView()
        view.setFont(font: .normal(size: 14))
        view.setTextColor(color: .gray9B)
        view.text = NSLocalizedString("ChatHere", value: SystemMessage.Information.ChatHere, comment: "")
        view.isUserInteractionEnabled = false
        view.isScrollEnabled = false
        view.scrollsToTop = false
        view.setBackgroundColor(color: .none)
        return view
    }()
    
    fileprivate let micButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        var image = UIImage(named: "mic", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
//        bt.setImage(UIImage(named:"icon_mic_active"), for: .selected)
        return bt
    }()
    
    fileprivate let photoButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        var image = UIImage(named: "photo", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    fileprivate let galleryButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "gallery", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        return button
    }()
    
    fileprivate let plusButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        var image = UIImage(named: "icon_more_menu", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    fileprivate let locationButton: UIButton = {

        let bt = UIButton(type: .custom)
//        bt.tintColor = .mainRed()
        var image = UIImage(named: "location_new", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        return bt
    }()

    fileprivate let chatButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "showKeyboard", in: Bundle.applozic, compatibleWith: nil)
//        image = image?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        return button
    }()

    fileprivate let lineImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "line", in: Bundle.applozic, compatibleWith: nil))
//        imageView.contentMode = .scaleToFill
        return imageView
    }()

    fileprivate let sendButton: UIButton = {
        
        let bt = UIButton(type: .custom)
        var image = UIImage(named: "send", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        bt.setImage(image, for: .normal)
        bt.accessibilityIdentifier = "sendButton"
        
        return bt
    }()
    
    private var lineView: UIView = {
        let view = UIView()
        let layer = view.layer
        view.backgroundColor = UIColor(colorLiteralRed: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        return view
    }()

    private var bottomGrayView: UIView = {
        let view = UIView()
        view.setBackgroundColor(color: .grayEF)
        view.isUserInteractionEnabled = false
        return view
    }()

    private var videoButton: UIButton = {
        let button = UIButton(type: .custom)
        var image = UIImage(named: "video", in: Bundle.applozic, compatibleWith: nil)
        image = image?.imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)

        return button
    }()
    
    
    func tapped(button: UIButton) {
        
        switch button {
        case sendButton:
            
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.lengthOfBytes(using: .utf8) > 0 {
                action?(.sendText(button,text))
            }
            
            break
            
        case plusButton:
            action?(.more(button))
            break
            
        case photoButton:
            
            let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.camera, bundle: Bundle.applozic)
            if let vc = storyboard.instantiateViewController(withIdentifier: "CustomCameraNavigationController") as? ALKBaseNavigationViewController {
                guard let firstVC = vc.viewControllers.first else {return}
                let cameraView = firstVC as! ALKCustomCameraViewController
                cameraView.setCustomCamDelegate(camMode: .NoCropOption, camDelegate: self)
                UIViewController.topViewController()?.present(vc, animated: false, completion: nil)
            }
            break
            
        case micButton:
            if soundRec.isHidden {
                micButton.isSelected = true
                soundRec.isHidden = false
                
                if placeHolder.isFirstResponder {
                    placeHolder.resignFirstResponder()
                } else if textView.isFirstResponder {
                    textView.resignFirstResponder()
                }
                
                soundRec.setSoundRecDelegate(recorderDelegate: self)
            } else {
                micButton.isSelected = false
                soundRec.isHidden = true
            }

        case videoButton:
            action?(.startVideoRecord())
            break
        case galleryButton:
            action?(.showImagePicker())
            break
        case locationButton:
            action?(.showLocation())
        case chatButton:
            textView.becomeFirstResponder()

        default: break

        }
    }
    
    fileprivate func toggleKeyboardType(textView: UITextView) {
        
        textView.keyboardType = .asciiCapable
        textView.reloadInputViews()
        textView.keyboardType = .default;
        textView.reloadInputViews()
    }
    
    private weak var comingSoonDelegate: UIView?
    
    var chatIdentifier: String?
    
    func setComingSoonDelegate(delegate: UIView) {
        comingSoonDelegate = delegate
    }
    
    func clear() {
        
        textView.text = ""
        clearTextInTextView()
        toggleKeyboardType(textView: textView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        locationButton.isHidden = true
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            textView.textAlignment = .right
        }

        textView.delegate = self
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        micButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        videoButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)

        setupConstraints()
    }
    
    deinit {
        
        micButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        plusButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        photoButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        sendButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        videoButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        galleryButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        locationButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)
        chatButton.removeTarget(self, action: #selector(tapped(button:)), for: .touchUpInside)


    }

    private var isNeedInitText = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isNeedInitText {
            
            guard let identifier = chatIdentifier else {
                return
            }

            isNeedInitText = false
        }
        
    }
    
    fileprivate var textViewHeighConstrain: NSLayoutConstraint?
    fileprivate let textViewHeigh: CGFloat = 40.0
    fileprivate let textViewHeighMax: CGFloat = 102.2 + 8.0
    
    fileprivate var textViewTrailingWithSend: NSLayoutConstraint?
    fileprivate var textViewTrailingWithMic: NSLayoutConstraint?
    
    private func setupConstraints() {
        plusButton.isHidden = true
        addViewsForAutolayout(views: [bottomGrayView, micButton, plusButton, photoButton, grayView,  textView, sendButton, lineImageView, videoButton, galleryButton,locationButton, chatButton, lineView, frameView, placeHolder,soundRec])

        lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        chatButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        chatButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        chatButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        chatButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        
        photoButton.leadingAnchor.constraint(equalTo: chatButton.trailingAnchor, constant: 30).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        photoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        micButton.leadingAnchor.constraint(equalTo: galleryButton.trailingAnchor, constant: 30).isActive = true
        micButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        micButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        micButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
        plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
        plusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true

        videoButton.leadingAnchor.constraint(equalTo: micButton.trailingAnchor, constant: 30).isActive = true
        videoButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        videoButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
//        videoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        videoButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        galleryButton.leadingAnchor.constraint(equalTo: photoButton.trailingAnchor, constant: 30).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        galleryButton.centerYAnchor.constraint(equalTo: bottomGrayView.centerYAnchor, constant: 0).isActive = true

        locationButton.leadingAnchor.constraint(equalTo: videoButton.trailingAnchor, constant: 30).isActive = true
        locationButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        locationButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true

        lineImageView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -15).isActive = true
        lineImageView.widthAnchor.constraint(equalToConstant: 2).isActive = true
        lineImageView.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10).isActive = true
        lineImageView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10).isActive = true

        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10).isActive = true
        
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomGrayView.topAnchor, constant: 0).isActive = true
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3).isActive = true
        
//        textViewTrailingWithMic = textView.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8).isActive
        textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor).isActive = true
        
        textViewHeighConstrain = textView.heightAnchor.constraint(equalToConstant: textViewHeigh)
        textViewHeighConstrain?.isActive = true
        
        placeHolder.heightAnchor.constraint(equalToConstant: 35).isActive = true
        placeHolder.centerYAnchor.constraint(equalTo: textView.centerYAnchor, constant: 0).isActive = true
        placeHolder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0).isActive = true
        placeHolder.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0).isActive = true
        
        soundRec.isHidden = true
        soundRec.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        soundRec.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        soundRec.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0).isActive = true
        soundRec.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0).isActive = true
        
        frameView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        frameView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0).isActive = true
        frameView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4).isActive = true
        frameView.rightAnchor.constraint(equalTo: rightAnchor, constant: 2).isActive = true
        
        grayView.topAnchor.constraint(equalTo: frameView.topAnchor, constant: 0).isActive = true
        grayView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 0).isActive = true
        grayView.leftAnchor.constraint(equalTo: frameView.leftAnchor, constant: 0).isActive = true
        grayView.rightAnchor.constraint(equalTo: frameView.rightAnchor, constant: 0).isActive = true
//        bottomGrayView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5).isActive = true
        bottomGrayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        bottomGrayView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        bottomGrayView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        bottomGrayView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    
        bringSubview(toFront: frameView)
        
        changeButtonStateTo(mode: textView.text.isEmpty ? ButtonMode.media : ButtonMode.send)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func changeButtonStateTo(mode: ButtonMode){
        
        if mode == .media {
            
//            self.textViewTrailingWithSend?.isActive = false
//            self.textViewTrailingWithMic?.isActive = true

//            self.micButton.isUserInteractionEnabled = true
//            self.plusButton.isUserInteractionEnabled = true
//            self.sendButton.isUserInteractionEnabled = false
//            
//            self.layoutIfNeeded()
//            
//            self.micButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//            self.plusButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//            self.sendButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)

//            self.micButton.alpha = 1
//            self.plusButton.alpha = 1
//            self.sendButton.alpha = 1

            
        } else {
            
//            self.textViewTrailingWithMic?.isActive = false
//            self.textViewTrailingWithSend?.isActive = true

//            self.micButton.isUserInteractionEnabled = false
//            self.plusButton.isUserInteractionEnabled = false
//            self.sendButton.isUserInteractionEnabled = true
//            
//            self.layoutIfNeeded()
//            
//            self.micButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)
//            self.plusButton.transform = CGAffineTransform.init(scaleX: 0, y: 0)
//            self.sendButton.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//            
//            self.micButton.alpha = 1
//            self.plusButton.alpha = 1
//            self.sendButton.alpha = 1

        }
    }
    
}

extension ALKChatBar: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        guard var text = textView.text as NSString? else {
            return true
        }
        
        text = text.replacingCharacters(in: range, with: string) as NSString
        
        changeButtonStateTo(mode: text == "" ? ButtonMode.media : ButtonMode.send)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        let font = textView.font ?? UIFont.font(.normal(size: 14.0))
        let attributes = [NSParagraphStyleAttributeName: style, NSFontAttributeName: font]
        let tv = UITextView(frame: textView.frame)
        tv.attributedText = NSAttributedString(string: text as String, attributes:attributes)
        
        let fixedWidth = textView.frame.size.width
        let size = tv.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if let textViewHeighConstrain = self.textViewHeighConstrain, size.height != textViewHeighConstrain.constant  {
            
            if size.height < self.textViewHeighMax {
                textViewHeighConstrain.constant = size.height > self.textViewHeigh ? size.height : self.textViewHeigh
            } else if textViewHeighConstrain.constant != self.textViewHeighMax {
                textViewHeighConstrain.constant = self.textViewHeighMax
            }
            
            textView.layoutIfNeeded()
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeHolder.isHidden = !textView.text.isEmpty
        self.placeHolder.alpha = textView.text.isEmpty ? 1.0 : 0.0
        
        if let selectedTextRange = textView.selectedTextRange {
            let line = textView.caretRect(for: selectedTextRange.start)
            let overflow = line.origin.y + line.size.height  - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top )
            
            if overflow > 0 {
                var offset = textView.contentOffset;
                offset.y += overflow + 8.2 // leave 8.2 pixels margin
                
                textView.setContentOffset(offset, animated: false)
            }
        }
        action?(.chatBarTextChange(photoButton))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        action?(.chatBarTextBeginEdit())
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0
                
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self else { return }
                    
                    weakSelf.textViewHeighConstrain?.constant = weakSelf.textViewHeigh
                    UIView.animate(withDuration: 0.15) {
                        weakSelf.layoutIfNeeded()
                    }
                }
            }
        }
        
        //clear inputview of textview
        textView.inputView = nil
        textView.reloadInputViews()
    }
    
    fileprivate func clearTextInTextView() {
        if textView.text.isEmpty {
            
            if self.placeHolder.isHidden {
                self.placeHolder.isHidden = false
                self.placeHolder.alpha = 1.0
                
                textViewHeighConstrain?.constant = textViewHeigh
                layoutIfNeeded()
            }
        }
        textView.inputView = nil
        textView.reloadInputViews()
        changeButtonStateTo(mode: textView.text.isEmpty ? ButtonMode.media : ButtonMode.send)
    }
}

extension ALKChatBar: ALKCustomCameraProtocol {
    
    func customCameraDidTakePicture(cropedImage: UIImage) {
        action?(.sendPhoto(photoButton, cropedImage))
    }
}

extension ALKChatBar: ALKSoundRecorderProtocol {
    
    func stopRecording() {
        soundRec.cancelAudioRecord()
    }
    
    func startRecordingAudio() {
        action?(.startVoiceRecord())
    }
    
    func finishRecordingAudio(soundData: NSData) {
        textView.resignFirstResponder()
        action?(.sendVoice(soundData))
    }
    
    func cancelRecordingAudio() {
        soundRec.isHidden = true
        micButton.isSelected = false
        textView.becomeFirstResponder()
    }
    
    func permissionNotGrant() {
        action?(.noVoiceRecordPermission())
    }
}
