//
//  ALKEmptyCell.swift
//  ApplozicSwift
//
//  Created by apple on 19/11/18.
//

import Foundation

 class  ALKEmptyView : UIView{

    @IBOutlet weak var startNewConversationButtonIcon: UIButton!
    @IBOutlet weak var conversationLabel: UILabel!

    // MARK: - Lifecycle
    class func instanceFromNib() -> ALKEmptyView {
        guard let view = UINib(nibName: "EmptyChatCell", bundle: Bundle.applozic).instantiate(withOwner: nil, options: nil).first as? ALKEmptyView else {
            fatalError("\("EmptyChatCell") don't existing")
        }
        return view
    }

}
