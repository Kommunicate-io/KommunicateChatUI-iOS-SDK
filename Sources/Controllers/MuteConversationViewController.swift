//
//  MuteConversationViewController.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 15/10/18.
//

import Foundation
import Applozic

@objc protocol Muteable: class {
    @objc func mute(conversation: ALMessage, forTime: Int64, atIndexPath: IndexPath)
}

class MuteConversationViewController: UIViewController, Localizable {
    
    var configuration: ALKConfiguration!
    
    var delegate: Muteable!
    var conversation: ALMessage!
    var indexPath: IndexPath!
    
    private let modalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let popupTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.numberOfLines = 1
        label.font = UIFont(name: "Helvetica", size: 14)
        return label
    }()
    
    private let timePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        let title = localizedString(forKey: "ConfirmButton", withDefaultValue: SystemMessage.ButtonName.Confirm, fileName: configuration.localizedStringFileName)
        button.setTitle(NSLocalizedString("ConfirmButton", value: SystemMessage.ButtonName.Confirm, comment: ""), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("ButtonCancel", value: SystemMessage.ButtonName.Cancel, comment: ""), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    private lazy var actionButtons: UIStackView = {
        let buttons = UIStackView(arrangedSubviews: [self.cancelButton, self.confirmButton])
        buttons.axis = .horizontal
        buttons.alignment = .center
        buttons.distribution = .fillEqually
        buttons.spacing = 10.0
        buttons.backgroundColor = UIColor.black
        return buttons
    }()
    
    lazy var timeValues: [String] = {
        let values = [
            localizedString(forKey: "EightHour", withDefaultValue: SystemMessage.MutePopup.EightHour, fileName: configuration.localizedStringFileName),
            localizedString(forKey: "OneWeek", withDefaultValue: SystemMessage.MutePopup.OneWeek, fileName: configuration.localizedStringFileName),
            localizedString(forKey: "OneYear", withDefaultValue: SystemMessage.MutePopup.OneYear, fileName: configuration.localizedStringFileName)
        ]
        return values
    }()
    
    init(delegate: Muteable, conversation: ALMessage, atIndexPath: IndexPath, configuration: ALKConfiguration) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.conversation = conversation
        self.indexPath = atIndexPath
        self.configuration = configuration
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(10, green: 10, blue: 10, alpha: 0.2)
        self.view.isOpaque = false
    }
    
    func updateTitle(_ text: String) {
        self.popupTitle.text = text
    }
    
    func selectPickerRow(_ row: Int) {
        timePicker.selectRow(row, inComponent: 0, animated: true)
    }
    
    func setUpPickerView() {
        //Picker view delegate and datasource
        timePicker.delegate = self
        timePicker.dataSource = self
        
        //Default set first row i.e. 8 hours
        selectPickerRow(0)
    }
    
    @objc func tappedConfirm() {
        
        switch timePicker.selectedRow(inComponent: 0) {
        case 0:
            // 8 hours
            let time: Int64 = 8*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        case 1:
            // 1 week
            let time: Int64 = 7*24*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        case 2:
            // 1 year
            let time: Int64 = 365*24*60*60*1000
            delegate.mute(conversation: self.conversation, forTime: Int64(time), atIndexPath: indexPath)
            
        default:
            print("This won't occur")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappedCancel() {
         self.dismiss(animated: true, completion: nil)
    }
    
    func setupViews() {
        self.view.addViewsForAutolayout(views: [modalView])
        
        modalView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        modalView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        modalView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        modalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        modalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true

        modalView.addViewsForAutolayout(views: [popupTitle, timePicker, actionButtons])
        
        popupTitle.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 10).isActive = true
        popupTitle.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -10).isActive = true
          popupTitle.topAnchor.constraint(equalTo: modalView.topAnchor, constant: 10).isActive = true

        timePicker.topAnchor.constraint(equalTo: popupTitle.bottomAnchor, constant: 2).isActive = true
        timePicker.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 2).isActive = true
        timePicker.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: 2).isActive = true
        
        actionButtons.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 2).isActive = true
        actionButtons.leadingAnchor.constraint(equalTo: modalView.leadingAnchor, constant: 2).isActive = true
        actionButtons.trailingAnchor.constraint(equalTo: modalView.trailingAnchor, constant: -2).isActive = true
        actionButtons.bottomAnchor.constraint(equalTo: modalView.bottomAnchor).isActive = true
        
        setUpPickerView()
        
        //Add button actions
        confirmButton.addTarget(self, action: #selector(tappedConfirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(tappedCancel), for: .touchUpInside)
        
    }
    
}

extension MuteConversationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.timeValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.timeValues[row]
    }
}
