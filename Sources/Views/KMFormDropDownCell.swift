//
//  KMFormDropDownCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 23/06/23.
//

import Foundation

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
    
    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .black
        return table
    }()
    
    
   @objc func tappedBUtton() {
        print("Pakka101 button clicked")
    }
   
    
   @objc func onSelection() {
        print("Pakka101 onSelection clicked")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelection))
            contentView.addGestureRecognizer(tapRecognizer)
        titleButton.addTarget(self, action: #selector(tappedBUtton), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DropDownOptionsCell.self, forCellReuseIdentifier: "cell")
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addConstraints() {
        addViewsForAutolayout(views: [titleButton, nameLabel, tableView])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            titleButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            titleButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            titleButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: titleButton.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: titleButton.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 200)

        ])
    }
}

extension KMFormDropDownCell : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let options = options  else{return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row].label
        
        return cell
    }
    
    
}
