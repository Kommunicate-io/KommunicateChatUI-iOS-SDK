//
//  FriendCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Kingfisher
import MGSwipeTableCell

protocol ALKFriendCellProtocol {
    func startVOIPWithFriend(atIndex:IndexPath)
    func startChatWithFriend(atIndex:IndexPath)
    func deleteFriend(atIndex:IndexPath)
}

class ALKFriendCell: MGSwipeTableCell {

    @IBOutlet var imgDisplay: UIImageView!
    @IBOutlet var lblDisplayName: UILabel!
    
    var delegateFriendCell: ALKFriendCellProtocol!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    //MARK: - UI control
    func setupUI()
    {
        imgDisplay.layer.cornerRadius = 0.5 * imgDisplay.bounds.size.width
        imgDisplay.clipsToBounds = true

        self.lblDisplayName.textColor = .text(.black00)
    }
    
    func setFriendCellDelegate(cellDelegate:ALKFriendCellProtocol,IndexPath:IndexPath)
    {
        self.delegateFriendCell = cellDelegate
        self.indexPath = IndexPath
        
        //configure left buttons
        let btnDelete = MGSwipeButton(title: "", icon: UIImage(named: "icon_delete_white", in: Bundle.applozic, compatibleWith: nil), backgroundColor: .background(.main), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.delegateFriendCell.deleteFriend(atIndex: self.indexPath)
            return true
        })
        
        btnDelete.frame.size = CGSize(width: 48, height: 48)
        self.leftButtons = [btnDelete]
        self.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
    }
    
    func update(friend: ALKIdentityProtocol)
    {
        //no actual data yet
        self.lblDisplayName.text = friend.displayName
        
        if friend.displayName == "Create Group" {
            imgDisplay.image = UIImage(named: "group_profile_picture", in: Bundle.applozic, compatibleWith: nil)
            return
        }
        
        //image
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
        if let tempURL: URL = friend.displayPhoto {
            let resource = ImageResource(downloadURL: tempURL)
            imgDisplay.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
            
        } else {
            imgDisplay.image = placeHolder
        }
        
        
    }

    @IBAction func voipPress(_ sender: Any) {
        self.delegateFriendCell.startVOIPWithFriend(atIndex: self.indexPath)
    }
    
    @IBAction func chatPress(_ sender: Any) {
        self.delegateFriendCell.startChatWithFriend(atIndex: self.indexPath)
    }
}
