//
//  ALKCheckMeVC.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 17/10/18.
//

import Foundation

public class ALKCheckMeVC: UIViewController {
    
    private let popupTitle: UILabel = {
        let label = UILabel()
        label.text = "BABY BABY"
        label.textColor = UIColor.black
        label.font = UIFont(name: "Helvetica", size: 14)
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("ConfirmButton", value: SystemMessage.ButtonName.Discard, comment: ""), for: .normal)
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
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    }
    
    @objc func tappedConfirm() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappedCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupViews() {
        self.view.addViewsForAutolayout(views: [popupTitle, actionButtons])
        
        popupTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        popupTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        actionButtons.topAnchor.constraint(equalTo: popupTitle.bottomAnchor, constant: 2).isActive = true
        actionButtons.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 2).isActive = true
        actionButtons.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -2).isActive = true
        actionButtons.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        //Add button actions
        confirmButton.addTarget(self, action: #selector(tappedConfirm), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(tappedCancel), for: .touchUpInside)
        
    }
    
}
