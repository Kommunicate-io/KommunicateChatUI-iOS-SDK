//
//  ALKCreateGroupViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//


import UIKit
import Kingfisher
import Applozic

protocol ALKCreateGroupChatAddFriendProtocol {
    func createGroupGetFriendInGroupList(friendsSelected: [ALKFriendViewModel],groupName:String,groupImgUrl:String, friendsAdded: [ALKFriendViewModel])
}

final class ALKCreateGroupViewController: ALKBaseViewController, Localizable {

    enum ALKAddContactMode: Localizable {
        case newChat
        case existingChat
        
        func navigationBarTitle(localizedStringFileName: String) -> String {
            switch self {
            case .newChat:
                return localizedString(forKey: "CreateGroupTitle", withDefaultValue: SystemMessage.NavbarTitle.createGroupTitle, fileName: localizedStringFileName)
            default:
                return localizedString(forKey: "EditGroupTitle", withDefaultValue: SystemMessage.NavbarTitle.editGroupTitle, fileName: localizedStringFileName)
            }
        }
        
        func doneButtonTitle(localizedStringFileName: String) -> String {
            return localizedString(forKey: "SaveButtonTitle", withDefaultValue: SystemMessage.ButtonName.Save, fileName: localizedStringFileName)
        }
    }

    var groupList = [ALKFriendViewModel]()
    var addedList = [ALKFriendViewModel]()
    var groupProfileImgUrl = ""
    var groupDelegate: ALKCreateGroupChatAddFriendProtocol!
    private var groupName:String = ""
    var addContactMode: ALKAddContactMode = ALKAddContactMode.newChat
    
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet fileprivate var btnCreateGroup: UIButton!
    @IBOutlet fileprivate var tblParticipants: UICollectionView!
    @IBOutlet fileprivate var txtfGroupName: ALKGroupChatTextField!
    
    @IBOutlet fileprivate weak var viewGroupImg: UIView!
    @IBOutlet fileprivate weak var imgGroupProfile: UIImageView!
    fileprivate var tempSelectedImg:UIImage!
    fileprivate var cropedImage: UIImage?

    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    fileprivate lazy var localizedStringFileName: String = configuration.localizedStringFileName
    
    var viewModel: ALKCreateGroupViewModel?
    
    private var createGroupBGColor: UIColor {
        return btnCreateGroup.isEnabled ? UIColor.mainRed() : UIColor.disabledButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        self.hideKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        txtfGroupName.resignFirstResponder()
        //self.hideKeyboard()
    }
    
    //MARK: - UI controller
    @IBAction func dismisssPress(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createGroupPress(_ sender: Any) {

        guard var groupName = self.txtfGroupName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            let msg = localizedString(forKey: "FillGroupName", withDefaultValue: SystemMessage.Warning.FillGroupName, fileName: localizedStringFileName)
            alert(msg: msg)
            return
        }
        
        if groupName.lengthOfBytes(using: .utf8) < 1 {
            let msg = localizedString(forKey: "FillGroupName", withDefaultValue: SystemMessage.Warning.FillGroupName, fileName: localizedStringFileName)
            alert(msg: msg)
            return
        }
        
        if self.groupDelegate != nil
        {
            if let image = cropedImage {

               //upload image first
                guard let uploadUrl = URL(string: ALUserDefaultsHandler.getBASEURL() + IMAGE_UPLOAD_URL) else {
                    NSLog("NO URL TO UPLOAD GROUP PROFILE IMAGE")
                    return
                }
                let downloadManager = ALKHTTPManager()
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                btnCreateGroup.isEnabled = false
                downloadManager.upload(image: image, uploadURL: uploadUrl, completion: {
                    imageUrlData in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.btnCreateGroup.isEnabled = true
                    }
                    guard let data = imageUrlData, let imageUrl = String(data: data, encoding: .utf8) else {
                        NSLog("GROUP PROFILE PICTURE UPDATE FAILED")
                        return
                    }
                    DispatchQueue.main.async {
                        self.groupDelegate.createGroupGetFriendInGroupList(friendsSelected: self.groupList, groupName: groupName, groupImgUrl: imageUrl, friendsAdded: self.addedList)
                    }
                })
                }
            else {

                if groupName == self.groupName {
                    groupName = ""
                }
                groupDelegate.createGroupGetFriendInGroupList(friendsSelected:groupList, groupName: groupName, groupImgUrl: groupProfileImgUrl, friendsAdded:addedList)
            }

            }
    }
    
    fileprivate func setupUI() {
        // Textfield Group name
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            txtfGroupName.textAlignment = .right
        }
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.lightGray
        view.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        txtfGroupName.layer.cornerRadius = 10
        txtfGroupName.layer.borderColor = UIColor.mainRed().cgColor
        txtfGroupName.layer.borderWidth = 1
        txtfGroupName.clipsToBounds = true
        txtfGroupName.delegate = self
        setupAttributedPlaceholder(textField: txtfGroupName)
        
        //set btns into circle
        viewGroupImg.layer.cornerRadius = 0.5 * viewGroupImg.frame.size.width
        viewGroupImg.clipsToBounds = true
        
        editLabel.text = localizedString(forKey: "Edit", withDefaultValue: SystemMessage.LabelName.Edit, fileName: localizedStringFileName)
        participantsLabel.text = localizedString(forKey: "Participants", withDefaultValue: SystemMessage.LabelName.Participants, fileName: localizedStringFileName)
        
        if addContactMode == .existingChat {
            // Button Create Group
            btnCreateGroup.layer.cornerRadius = 15
            btnCreateGroup.clipsToBounds = true
            btnCreateGroup.setTitle(addContactMode.doneButtonTitle(localizedStringFileName: localizedStringFileName), for: UIControlState.normal)
        } else {
            btnCreateGroup.isHidden = true
        }
        
        txtfGroupName.text = self.groupName
        
        updateCreateGroupButtonUI(contactInGroup: groupList.count,
                                  groupname: txtfGroupName.trimmedWhitespaceText())
        
        self.tblParticipants.reloadData()
        self.title = addContactMode.navigationBarTitle(localizedStringFileName: localizedStringFileName)
        
        if let url = URL.init(string: groupProfileImgUrl) {
            let placeHolder = UIImage(named: "group_profile_picture-1", in: Bundle.applozic, compatibleWith: nil)
            let resource = ImageResource(downloadURL: url, cacheKey:groupProfileImgUrl)
            imgGroupProfile.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
//            imgGroupProfile.cropRedProfile()

        }

    }
    
    private func setupAttributedPlaceholder(textField: UITextField) {
        let style           = NSMutableParagraphStyle()
        style.alignment     = .left
        style.lineBreakMode = .byWordWrapping
        
        guard let font      = UIFont(name: "HelveticaNeue-Italic", size: 14) else { return }
        let attr:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.font:font,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue):style,
            NSAttributedStringKey.foregroundColor: UIColor.placeholderGray()
        ]
        
        let typeGroupNameMsg = localizedString(forKey: "TypeGroupName", withDefaultValue: SystemMessage.LabelName.TypeGroupName, fileName: localizedStringFileName)
            textField.attributedPlaceholder  = NSAttributedString(string: typeGroupNameMsg, attributes: attr)
    }
    
    @IBAction private func selectGroupImgPress(_ sender: Any) {
        guard
            let vc = ALKCustomCameraViewController.makeInstanceWith(delegate: self, and: configuration)
            else {return}
            self.present(vc, animated: false, completion: nil)
    }

    private func getPictureFilename() -> String {
        let name = ""

        // Add user id
//        if let userID = ChatManager.shared.userID {
//            name = name + userID
//        }

        // Add time
        let dateFormatter       = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString          = dateFormatter.string(from: Date())
        return name + "_" + dateString + "_profile.png"
    }
    
    func setCurrentGroupSelected(groupName: String, groupProfileImg: String?, groupSelected:[ALKFriendViewModel],delegate: ALKCreateGroupChatAddFriendProtocol) {
        // TODO: Plan to use groupname from view model
        viewModel = ALKCreateGroupViewModel(groupName: groupName)
        self.groupName = groupName
        self.groupDelegate = delegate
        self.groupList = groupSelected
        
        guard let gImgUrl = groupProfileImg else {return}
        groupProfileImgUrl = gImgUrl
        
    }
    
    private func isAtLeastOneContact(contactCount: Int) -> Bool {
        return contactCount > 0
    }
    
    private func changeCreateGroupButtonState(isEnabled: Bool) {
        btnCreateGroup.isEnabled = isEnabled
        btnCreateGroup.backgroundColor = createGroupBGColor
    }
    
    fileprivate func updateCreateGroupButtonUI(contactInGroup: Int, groupname: String) {
        guard isAtLeastOneContact(contactCount: contactInGroup) else {
            changeCreateGroupButtonState(isEnabled: false)
            return
        }
        guard !groupname.isEmpty else {
            changeCreateGroupButtonState(isEnabled: false)
            return
        }
        changeCreateGroupButtonState(isEnabled: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectFriendToAdd" {
            
            let selectParticipantViewController = segue.destination as? ALKSelectParticipantToAddViewController
            selectParticipantViewController?.selectParticipantDelegate = self
            selectParticipantViewController?.friendsInGroup = self.groupList
            selectParticipantViewController?.configuration = configuration
        }
    }

    override func backTapped() {
        guard let createGroupViewModel = viewModel else {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        guard let navigationController = navigationController else { return }

        
        let cancelTitle = localizedString(forKey: "ButtonCancel", withDefaultValue: SystemMessage.ButtonName.Cancel, fileName: localizedStringFileName)
        let discardTitle = localizedString(forKey: "ButtonDiscard", withDefaultValue: SystemMessage.ButtonName.Discard, fileName: localizedStringFileName)
        let alertTitle = localizedString(forKey: "DiscardChangeTitle", withDefaultValue: SystemMessage.LabelName.DiscardChangeTitle, fileName: localizedStringFileName)
        let alertMessage = localizedString(forKey: "DiscardChangeMessage", withDefaultValue: SystemMessage.Warning.DiscardChange, fileName: localizedStringFileName)
        
        UIAlertController.presentDiscardAlert(onPresenter: navigationController, alertTitle: alertTitle, alertMessage: alertMessage, cancelTitle: cancelTitle, discardTitle: discardTitle,
                                              onlyForCondition: { () -> Bool in
                                                return (
                                                    createGroupViewModel.groupName != createGroupViewModel.originalGroupName || cropedImage != nil
                                                )
        }) { [weak self] in
            guard let weakSelf = self else { return }
            _ = weakSelf.navigationController?.popViewController(animated: true)
        }
    }
}

extension ALKCreateGroupViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.groupList.count == 0) {
            return 1//just an add button
        } else {
            return self.groupList.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.tblParticipants.dequeueReusableCell(withReuseIdentifier:"ALKAddParticipantCollectionCell", for: indexPath) as! ALKAddParticipantCollectionCell
        
        if(indexPath.row == self.groupList.count) {
            //it's an added btn
            cell.setDelegate(friend: nil, atIndex: indexPath, delegate: self)
            
            guard let viewModel = viewModel else { return cell }
            cell.setStatus(isAddButtonEnabled: viewModel.isAddParticipantButtonEnabled())
        } else if (self.groupList.count == 0) {
            //it's an added btn
            cell.setDelegate(friend: nil, atIndex: indexPath, delegate: self)
            guard let viewModel = viewModel else { return cell }
            cell.setStatus(isAddButtonEnabled: viewModel.isAddParticipantButtonEnabled())
        } else {
            let temp = self.groupList[indexPath.row]
            cell.setDelegate(friend: temp, atIndex: indexPath, delegate: self)
        }
        return cell
    }
}

extension ALKCreateGroupViewController:ALKAddParticipantProtocol
{
    func addParticipantAtIndex(atIndex: IndexPath) {
        if (atIndex.row == self.groupList.count || self.groupList.count == 0) {
            txtfGroupName.resignFirstResponder()
            self.performSegue(withIdentifier: "goToSelectFriendToAdd", sender: nil)
        }
    }

    func profileTappedAt(index: IndexPath) {
        guard addContactMode == .existingChat,
            index.row < groupList.count else {return}
        let user = groupList[index.row]
        let viewModel = ALKConversationViewModel(contactId: user.friendUUID, channelKey: nil, localizedStringFileName: configuration.localizedStringFileName)

        let conversationVC = ALKConversationViewController(configuration: configuration)
        conversationVC.viewModel = viewModel
        conversationVC.title = user.friendProfileName
        self.navigationController?.pushViewController(conversationVC, animated: true)

    }
}


extension ALKCreateGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtfGroupName?.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text as NSString?
        if let text  = str?.replacingCharacters(in: range, with: string) {
            updateCreateGroupButtonUI(contactInGroup: groupList.count, groupname: text)
            
            guard let viewModel = viewModel else { return true }
            
            let oldStatus = viewModel.isAddParticipantButtonEnabled()
            
            viewModel.groupName = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let newStatus = viewModel.isAddParticipantButtonEnabled()
            if oldStatus != newStatus {
                tblParticipants.reloadData()
            }
        }
        return true
    }
}


extension ALKCreateGroupViewController: ALKSelectParticipantToAddProtocol {
    func selectedParticipant(selectedList: [ALKFriendViewModel], addedList: [ALKFriendViewModel]) {
        self.groupList = selectedList
        self.addedList = addedList
        
        //createGroup()
        self.createGroupPress(btnCreateGroup)
        
        /*
        self.tblParticipants.reloadData()
        
        updateCreateGroupButtonUI(contactInGroup: groupList.count, groupname: txtfGroupName.trimmedWhitespaceText())
        */
    }
    
    private func createGroup() {
        guard let groupName = self.txtfGroupName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if groupName.lengthOfBytes(using: .utf8) < 1 {
            return
        }
        
        if self.groupDelegate != nil {
            self.groupDelegate.createGroupGetFriendInGroupList(friendsSelected: self.groupList,
                                                               groupName: groupName,groupImgUrl:"",
                                                               friendsAdded: self.addedList)
        }
    }
}

extension ALKCreateGroupViewController
{
    override func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ALKCreateGroupViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        txtfGroupName.resignFirstResponder()
        view.endEditing(true)
    }
    
}

extension ALKCreateGroupViewController:ALKCustomCameraProtocol
{
    func customCameraDidTakePicture(cropedImage: UIImage) {
        // Be back from cropiing camera page
        self.tempSelectedImg = self.imgGroupProfile.image
        self.imgGroupProfile.image = cropedImage
        self.cropedImage = cropedImage
    }
}
