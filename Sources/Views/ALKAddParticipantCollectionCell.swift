//
//  ALKAddParticipantCollectionCell.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//


import UIKit
import Kingfisher
protocol ALKAddParticipantProtocol: class {
    func addParticipantAtIndex(atIndex:IndexPath)
    func profileTappedAt(index: IndexPath)
}

final class ALKAddParticipantCollectionCell: UICollectionViewCell {
    
    var currentFriendViewModel:ALKFriendViewModel?
    var indexPath:IndexPath?
    weak var delegate:ALKAddParticipantProtocol?
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnAdd: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    //MARK: - SetupUI
    func setupUI()
    {
        imgView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        imgView.addGestureRecognizer(tapGesture)

        //set profile pic into circle
        imgView.layer.cornerRadius = 0.5 * imgView.frame.size.width
        //imgView.layer.borderColor = UIColor.white.cgColor
        //imgView.layer.borderWidth = 2
        imgView.clipsToBounds = true
        
        btnAdd.setImage(UIImage(named: "icon_add_people-1", in: Bundle.applozic, compatibleWith: nil), for: .normal)
        btnAdd.setImage(UIImage(named: "icon_add_people_grey", in: Bundle.applozic, compatibleWith: nil), for: .disabled)
        btnAdd.layer.cornerRadius = 0.5 * btnAdd.frame.size.width
        //btnAdd.layer.borderColor = UIColor.white.cgColor
        //btnAdd.layer.borderWidth = 2
        btnAdd.clipsToBounds = true
    }
    
    func setDelegate(friend:ALKFriendViewModel?, atIndex:IndexPath,delegate:ALKAddParticipantProtocol)
    {
        //setupUI()
        
        self.indexPath = atIndex
        self.delegate = delegate
        
        if(friend != nil)
        {
            self.lblName.isHidden = false
            self.imgView.isHidden = false
            self.btnAdd.isHidden = true
            self.currentFriendViewModel = friend
            self.lblName.text = self.currentFriendViewModel?.getFriendDisplayName()
            
            //image
            let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)
            let tempURL:URL = self.currentFriendViewModel!.friendDisplayImgURL!
            let resource = ImageResource(downloadURL: tempURL, cacheKey:tempURL.absoluteString)
            imgView.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else
        {
            //an add button
            self.lblName.isHidden = true
            self.imgView.isHidden = true
            self.btnAdd.isHidden = false
        }
    }
    
    func setStatus(isAddButtonEnabled: Bool) {
        if btnAdd.isHidden == false {
            btnAdd.isEnabled = isAddButtonEnabled
        }
    }
    
    //MARK: - UI Control
    @IBAction func addParticipantPress(_ sender: Any) {
        delegate?.addParticipantAtIndex(atIndex: self.indexPath!)
    }

    @objc func profileTapped() {
        delegate?.profileTappedAt(index: self.indexPath!)
    }
    
}
