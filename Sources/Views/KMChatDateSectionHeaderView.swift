//
//  KMChatDateSectionHeaderView.swift
//
//
//  Created by Mukesh Thawani on 04/05/17.
//

import UIKit

class KMChatDateSectionHeaderView: UIView {
    // MARK: - Variables and Types

    // MARK: ChatDate

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dateView: UIView! {
        didSet {
            dateView.layer.cornerRadius = dateView.frame.size.height / 2.0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dateView?.layer.cornerRadius = (dateView?.bounds.height ?? 0) / 2.0
    }

    // MARK: - Lifecycle

    class func instanceFromNib() -> KMChatDateSectionHeaderView {
        let bundle = Bundle.km
        let objects = UINib(nibName: KMChatDateSectionHeaderView.nibName, bundle: bundle).instantiate(withOwner: nil, options: nil)
        if let view = objects.first(where: { $0 is KMChatDateSectionHeaderView }) as? KMChatDateSectionHeaderView {
            return view
        }

        print("Unable to load \(KMChatDateSectionHeaderView.nibName) from bundle: \(bundle.bundlePath). Loaded objects: \(objects.map { String(reflecting: type(of: $0)) })")
        return makeProgrammaticView()
    }

    private class func makeProgrammaticView() -> KMChatDateSectionHeaderView {
        let headerView = KMChatDateSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 375, height: 40))
        let dateContainerView = UIView()
        let label = UILabel()

        headerView.backgroundColor = .clear
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Today"
        label.textAlignment = .center

        headerView.addSubview(dateContainerView)
        dateContainerView.addSubview(label)
        headerView.dateView = dateContainerView
        headerView.dateLabel = label

        NSLayoutConstraint.activate([
            dateContainerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dateContainerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.topAnchor.constraint(equalTo: dateContainerView.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor, constant: -8)
        ])

        headerView.setupViewStyle()
        return headerView
    }

    // MARK: - Methods of class

    // MARK: ChatDate

    func setupDate(withDateFormat date: String) {
        dateLabel.text = date
    }

    func setupViewStyle() {
        backgroundColor = UIColor.clear
        let dateCellStyle = KMChatMessageStyle.dateSeparator
        dateView.backgroundColor = dateCellStyle.background
        dateLabel.backgroundColor = dateCellStyle.background
        dateLabel.textColor = dateCellStyle.text
        dateLabel.setFont(dateCellStyle.font)
    }
}
