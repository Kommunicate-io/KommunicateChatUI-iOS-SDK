//
//  UIAlertController+Extension.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    static func makeCancelDiscardAlert(title: String, message: String, discardAction: @escaping ()->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: NSLocalizedString("ButtonCancel", value: SystemMessage.ButtonName.Cancel, comment: ""), style: .cancel, handler: nil)
        let discardButton = UIAlertAction(title: NSLocalizedString("ButtonDiscard", value: SystemMessage.ButtonName.Discard, comment: ""),
                                          style: .destructive,
                                          handler: { (alert) in
                                            discardAction()
        })
        alert.addAction(cancelButton)
        alert.addAction(discardButton)
        return alert
    }
    
    static func presentDiscardAlert(onPresenter presenter: UIViewController, onlyForCondition condition: () -> Bool, lastAction: @escaping () -> ()) {
        if (condition()) {
                let alert = makeCancelDiscardAlert(title: NSLocalizedString("DiscardChangeTitle",value: ALKAlertInformation.discardChange.title, comment: ""),
                                                   message: NSLocalizedString("DiscardChangeMessage",value: ALKAlertInformation.discardChange.message, comment: ""),
                                                   discardAction: {
                                                    lastAction()
                })
            presenter.present(alert, animated: true, completion: nil)
        } else {
            lastAction()
        }
    }
}
