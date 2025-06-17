//
//  KMChatAddParticipantCollectionCell.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Kingfisher
import UIKit
protocol KMChatAddParticipantProtocol: AnyObject {
    func addParticipantAtIndex(atIndex: IndexPath)
    func profileTappedAt(index: IndexPath)
}

final class KMChatAddParticipantCollectionCell: UICollectionViewCell {
    var currentFriendViewModel: KMChatFriendViewModel?
    var indexPath: IndexPath?
    weak var delegate: KMChatAddParticipantProtocol?

    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var btnAdd: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    // MARK: - SetupUI

    func setupUI() {
        imgView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        imgView.addGestureRecognizer(tapGesture)

        // set profile pic into circle
        imgView.layer.cornerRadius = 0.5 * imgView.frame.size.width
        // imgView.layer.borderColor = UIColor.white.cgColor
        // imgView.layer.borderWidth = 2
        imgView.clipsToBounds = true

        btnAdd.setImage(UIImage(named: "icon_add_people-1", in: Bundle.km, compatibleWith: nil), for: .normal)
        btnAdd.setImage(UIImage(named: "icon_add_people_grey", in: Bundle.km, compatibleWith: nil), for: .disabled)
        btnAdd.layer.cornerRadius = 0.5 * btnAdd.frame.size.width
        // btnAdd.layer.borderColor = UIColor.white.cgColor
        // btnAdd.layer.borderWidth = 2
        btnAdd.clipsToBounds = true
    }

    func setDelegate(friend: KMChatFriendViewModel?, atIndex: IndexPath, delegate: KMChatAddParticipantProtocol) {
        // setupUI()

        indexPath = atIndex
        self.delegate = delegate

        if friend != nil {
            lblName.isHidden = false
            imgView.isHidden = false
            btnAdd.isHidden = true
            currentFriendViewModel = friend
            lblName.text = currentFriendViewModel?.getFriendDisplayName()

            // image
            let placeHolder = UIImage(named: "placeholder", in: Bundle.km, compatibleWith: nil)
            let tempURL: URL = currentFriendViewModel!.friendDisplayImgURL!
            let resource = Kingfisher.ImageResource(downloadURL: tempURL, cacheKey: tempURL.absoluteString)
            imgView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            // an add button
            lblName.isHidden = true
            imgView.isHidden = true
            btnAdd.isHidden = false
        }
    }

    func setStatus(isAddButtonEnabled: Bool) {
        if btnAdd.isHidden == false {
            btnAdd.isEnabled = isAddButtonEnabled
        }
    }

    // MARK: - UI Control

    @IBAction func addParticipantPress(_: Any) {
        delegate?.addParticipantAtIndex(atIndex: indexPath!)
    }

    @objc func profileTapped() {
        delegate?.profileTappedAt(index: indexPath!)
    }
}
