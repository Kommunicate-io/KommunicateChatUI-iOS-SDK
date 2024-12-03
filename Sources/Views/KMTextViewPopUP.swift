//
//  KMTextViewPopUP.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan on 16/10/24.
//

import UIKit

class KMTextViewPopUPVC: UIViewController {
    
    let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let closeButton: KMExtendedTouchAreaButton = {
        let button = KMExtendedTouchAreaButton(type: .system)
        button.extraTouchArea = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        button.setImage(UIImage(named: "close", in: Bundle.km, compatibleWith: nil), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xEFEFEF)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    func update(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        setupConstraints()
    }
    
    func setupConstraints() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(popupView)
        
        popupView.addSubview(titleLabel)
        popupView.addSubview(closeButton)
        popupView.addSubview(separatorLine)
        popupView.addSubview(scrollView)
        scrollView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 14),
            closeButton.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: popupView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    @objc func closePopup() {
        dismiss(animated: false, completion: nil)
    }
}

