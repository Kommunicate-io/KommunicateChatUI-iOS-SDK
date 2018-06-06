//
//  ALKAccountSuspensionController.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 05/06/18.
//

import UIKit

class ALKAccountSuspensionController: UIViewController {

    var closePressed: (()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        guard
            let accountView = Bundle.applozic.loadNibNamed("ALKAccountSuspensionView", owner: self, options: nil)?
                .first as? UIView else { return }
        accountView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height-50)
        view.addSubview(accountView)
        view.addSubview(closeButtonOf(frame: CGRect(x: 20, y: 20, width: 30, height: 30)))
    }

    @objc func closeButtonAction(_ button: UIButton) {
        let popVC = navigationController?.popViewController(animated: true)
        if popVC == nil {
            self.dismiss(animated: true, completion: nil)
        }
        closePressed?()
    }

    private func closeButtonOf(frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        let closeImage = UIImage(named: "close", in: Bundle.applozic, compatibleWith: nil)
        button.setImage(closeImage, for: .normal)
        button.tintColor = UIColor.black
        return button
    }
}
