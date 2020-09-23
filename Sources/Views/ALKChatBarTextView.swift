//
//  ALChatBarTextView.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

open class ALKChatBarTextView: UITextView {
    weak var overrideNextResponder: UIResponder?

    override open var next: UIResponder? {
        if let overrideNextResponder = self.overrideNextResponder {
            return overrideNextResponder
        }

        return super.next
    }

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if overrideNextResponder != nil {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

    override open var text: String! {
        get { return super.text }
        set {
            let didChange = super.text != newValue
            super.text = newValue
            if didChange {
                delegate?.textViewDidChange?(self)
            }
        }
    }

    override open var attributedText: NSAttributedString! {
        get { return super.attributedText }
        set {
            let didChange = super.attributedText != newValue
            super.attributedText = newValue
            if didChange {
                delegate?.textViewDidChange?(self)
            }
        }
    }

    override open var delegate: UITextViewDelegate? {
        get { return self }
        set { _ = newValue } // To satisfy the linter otherwise this would be an empty setter
    }

    private let delegates: NSHashTable<UITextViewDelegate> = NSHashTable.weakObjects()

    func add(delegate: UITextViewDelegate) {
        delegates.add(delegate)
    }

    func remove(delegate: UITextViewDelegate) {
        for oneDelegate in delegates.allObjects.reversed() where oneDelegate === delegate {
            delegates.remove(oneDelegate)
        }
    }

    fileprivate func invoke(invocation: (UITextViewDelegate) -> Void) {
        for delegate in delegates.allObjects.reversed() {
            invocation(delegate)
        }
    }
}

extension ALKChatBarTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        invoke { _ = $0.textView?(textView, shouldChangeTextIn: range, replacementText: text) }
        return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        invoke { $0.textViewDidChangeSelection?(textView) }
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        invoke { $0.textViewDidBeginEditing?(textView) }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        invoke { $0.textViewDidEndEditing?(textView) }
    }

    public func textViewDidChange(_ textView: UITextView) {
        invoke { $0.textViewDidChange?(textView) }
    }
}
