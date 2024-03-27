//
//  KMFormDropDownCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 23/06/23.
//

import Foundation
import UIKit
import iOSDropDown

protocol KMFormDropDownSelectionProtocol {
    func optionSelected(position: Int,selectedText: String?,index:Int)
    func defaultOptionSelected(position: Int,selectedText: String?,index:Int)
}

class KMFormDropDownCell: UITableViewCell {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let currentMode = traitCollection.userInterfaceStyle
        if let previousMode = previousTraitCollection?.userInterfaceStyle,
               previousMode != currentMode {
            updateDropdownAppearance()
        }
    }
    
    private lazy var errorStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .horizontal
        labelStackView.alignment = .fill
        labelStackView.distribution = .fillEqually
        labelStackView.backgroundColor = UIColor.clear
        return labelStackView
    }()
    
    /// Update dropdown appearance based on the UI mode
    private func updateDropdownAppearance() {
        menu.selectedRowColor = FormDropDownStyle.Color.selectedRowBackgroundColor
        menu.rowBackgroundColor = FormDropDownStyle.Color.rowBackgroundColor
        menu.textColor = FormDropDownStyle.Color.textColor
        menu.arrowColor = FormDropDownStyle.Color.arrowColor
        menu.itemsColor = FormDropDownStyle.Color.optionsTextColor
    }

    
    let errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .red
        label.font = Font.normal(size: 15).font()
        label.textAlignment = .left
        return label
    }()
    
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelDropdownItem else {
                return
            }
            name = item.name
            nameLabel.text = item.title
            options = item.options
            guard var options = options, !options.isEmpty else { return }
            
            var selectedIndex = 0
            
            for (index, item) in options.enumerated() {
                if let selected = item.selected, selected {
                    selectedIndex = index
                    addDefultDataInCache(position: self.menu.tag, selectedText: item.value, index: index)
                }
            }
            
            menu.selectedIndex = selectedIndex
            menu.text = options[selectedIndex].label
            
            for (index, item) in options.enumerated() {
                if let disabled = item.disabled, disabled && item.selected != nil {
                    options.remove(at: index)
                } else {
                    optionsDict[item.label] = item
                }
            }
            
            let labelList = options.map({$0.label})
            menu.optionArray = labelList
        }
    }
    
    var options: [KMFormTemplate.Option]? = nil
    var name: String = ""
    var optionsDict: [String: KMFormTemplate.Option] = [:]
    var delegate: KMFormDropDownSelectionProtocol?
    var identifier: String?
    
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 17).font()
        label.textColor = .kmDynamicColor(light: .black, dark: .white)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let  menu : DropDown = {
        let dropdown = DropDown(frame: .zero)
        dropdown.selectedRowColor = FormDropDownStyle.Color.selectedRowBackgroundColor
        dropdown.rowBackgroundColor = FormDropDownStyle.Color.rowBackgroundColor
        dropdown.rowHeight = FormDropDownStyle.Size.rowHeight
        dropdown.listHeight = FormDropDownStyle.Size.listHeight
        dropdown.textColor = FormDropDownStyle.Color.textColor
        dropdown.arrowSize = FormDropDownStyle.Size.arrowSize
        dropdown.arrowColor = UIColor.kmDynamicColor(light: FormDropDownStyle.Color.arrowColor, dark: .white)
        dropdown.itemsColor = FormDropDownStyle.Color.optionsTextColor
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
        contentView.backgroundColor = UIColor.kmDynamicColor(light: .white, dark: UIColor.appBarDarkColor())
        menu.delegate = self
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addDefultDataInCache(position: Int,selectedText: String?,index:Int) {
        DispatchQueue.main.async {
            self.delegate?.defaultOptionSelected(position: position, selectedText: selectedText, index: index)
        }
    }
    
    private func addConstraints() {
        addViewsForAutolayout(views: [view, nameLabel, errorStackView])
        errorStackView.addArrangedSubview(errorLabel)
        errorStackView.bringSubviewToFront(errorLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            view.heightAnchor.constraint(equalToConstant: FormDropDownStyle.Size.dropdownBoxHeight),
            view.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            view.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
        
        errorStackView.layout {
            $0.leading == nameLabel.leadingAnchor
            $0.trailing == nameLabel.trailingAnchor
            $0.top == view.bottomAnchor + 10
            $0.bottom <= bottomAnchor - 10
        }
        
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
            self.delegate?.optionSelected(position: self.menu.tag, selectedText: selectedvalue.value ?? nil, index: index)
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
        public static var selectedRowBackgroundColor : UIColor = UIColor.init(hexString: "#87CEFA")
        public static var rowBackgroundColor: UIColor = UIColor.kmDynamicColor(light: UIColor.white, dark: UIColor.backgroundDarkColor())
        public static var textColor: UIColor = UIColor.kmDynamicColor(light: UIColor.gray, dark: UIColor.white)
        public static var arrowColor: UIColor = UIColor.kmDynamicColor(light: UIColor.black, dark: UIColor.white)
        public static var optionsTextColor: UIColor = UIColor.kmDynamicColor(light: .darkGray, dark: .lightText)
    }
    
    public struct Size {
        public static var rowHeight: CGFloat = 30.0
        public static var listHeight: CGFloat = 150.0
        public static var dropdownBoxHeight: CGFloat = 40.0
        public static var arrowSize : CGFloat = 15.0
    }
}
