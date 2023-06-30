//
//  KMFormDropDownCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 23/06/23.
//

import Foundation
import UIKit
import iOSDropDown

protocol KMFormDropDownSelectionProtocol{
    func optionSelected(position: Int,selectedText: String)
}

class KMFormDropDownCell: UITableViewCell {
    
    
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelDropdownItem else {
                return
            }
            name = item.name
            nameLabel.text = item.title
            menu.placeholder = nameLabel.text
            options = item.options
            guard let options = options, !options.isEmpty else { return }
            let labelList = options.map({$0.label})
            menu.optionArray = labelList
            for item in options {
                optionsDict[item.label] = item
            }
        }
    }
    
    var options: [FormTemplate.Option]? = nil
    var name: String = ""
    var optionsDict: [String: FormTemplate.Option] = [:]
    var delegate: KMFormDropDownSelectionProtocol?
    
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 17).font()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let  menu : DropDown = {
        let dropdown = DropDown(frame: .zero)
        dropdown.checkMarkEnabled = false
        dropdown.selectedRowColor = FormDropDownStyle.Color.selectedRowBackgroundColor
        dropdown.rowBackgroundColor = FormDropDownStyle.Color.rowBackgroundColor
        dropdown.rowHeight = FormDropDownStyle.Size.rowHeight
        dropdown.listHeight = FormDropDownStyle.Size.listHeight
        dropdown.textColor = FormDropDownStyle.Color.textColor
        dropdown.arrowSize = FormDropDownStyle.Size.arrowSize
        dropdown.arrowColor = FormDropDownStyle.Color.arrowColor
        return dropdown
    }()

    
    let view: UIView = {
        let view = UIView(frame: .zero)
        view.layer.cornerRadius = 4
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        menu.delegate = self
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [view, nameLabel])
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            view.heightAnchor.constraint(equalToConstant: FormDropDownStyle.Size.dropdownBoxHeight),
            view.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            view.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        view.addViewsForAutolayout(views: [menu])
        menu.heightAnchor.constraint(equalToConstant: FormDropDownStyle.Size.dropdownBoxHeight).isActive = true
        menu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        menu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        menu.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        menu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true

        menu.didSelect{(selectedText , index ,id) in
            guard let selectedvalue = self.optionsDict[selectedText]
            else {
                print("Could not retreive selected option in Dropdown Menu")
                return
            }
            self.delegate?.optionSelected(position: self.menu.tag, selectedText: selectedvalue.value)
        }
    }
}

extension KMFormDropDownCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.menu.endEditing(true)
        self.menu.showList()
    }
}

public struct FormDropDownStyle {
    public struct Color {
        public static var selectedRowBackgroundColor : UIColor = UIColor.green
        public static var rowBackgroundColor: UIColor = UIColor.white
        public static var textColor: UIColor = UIColor.gray
        public static var arrowColor: UIColor = .black
    }
    
    public struct Size {
        public static var rowHeight: CGFloat = 30.0
        public static var listHeight: CGFloat = 150.0
        public static var dropdownBoxHeight: CGFloat = 40.0
        public static var arrowSize : CGFloat = 15.0
    }
}
