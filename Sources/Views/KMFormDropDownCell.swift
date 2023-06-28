//
//  KMFormDropDownCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 23/06/23.
//

import Foundation
import DropDown

class DropDownOptionsCell: UITableViewCell {}


class KMFormDropDownCell: UITableViewCell {
   
    var item: FormViewModelItem? {
        didSet {
            guard let item = item as? FormViewModelDropdownItem else {
                return
            }
            nameLabel.text = item.title
            titleButton.setTitle("Profession", for: .normal)
            options = item.options
            guard let options = options, !options.isEmpty else{return}
            let ite = options.map({$0.label})
            menu.dataSource = ite
//            /["Sathyan", "Aman","Pranay", "Adarsh","Rajeev"]
//            menu.show()
//            // Action triggered on selection
//            menu.cellConfiguration = { [unowned self] (index, item) in
//                return options[index].label
//            }
            
            print("Pakka101 \(ite)")
            menu.selectionAction = { [unowned self] (index: Int, item: String) in
              print("Selected item: \(item) at index: \(index)")
                titleButton.setTitle(item, for: .normal)
            }

            // Will set a custom width instead of the anchor view width
//            menu.width = 200

        }
    }
    
    var options: [FormViewModelDropdownItem.Option]? = nil
    
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Font.medium(size: 17).font()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    let titleButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Font.medium(size: 15).font()
        button.backgroundColor = .blue
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = CGFloat(2.0)
        button.isEnabled = true
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let menu: DropDown = {
        let menu = DropDown()
        return menu
    }()
        
    
   @objc func tappedBUtton() {
        print("Pakka101 button clicked")
       menu.show()
    }
   
    
   @objc func onSelection() {
        print("Pakka101 onSelection clicked")
//       menu.show()
       
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelection))
            contentView.addGestureRecognizer(tapRecognizer)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(DropDownOptionsCell.self, forCellReuseIdentifier: "cell")
        addConstraints()
        titleButton.addTarget(self, action: #selector(tappedBUtton), for: .touchUpInside)

    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [titleButton, nameLabel])

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            titleButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            titleButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            titleButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            titleButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10)
            
//            tableView.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 0),
//            tableView.leadingAnchor.constraint(equalTo: titleButton.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: titleButton.trailingAnchor),
//
//            tableView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 200)

        ])
        
        // The view to which the drop down will appear on
        menu.anchorView = titleButton
        
        

    }
}

