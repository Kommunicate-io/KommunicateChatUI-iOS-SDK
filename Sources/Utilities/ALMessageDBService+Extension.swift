//
//  ALMessageDBService+Extension.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 13/05/19.
//

import Applozic

extension ALMessageDBService {
    func updateDbMessageWith(key: String, value: String, filePath: String) {
        let messageService = ALMessageDBService()
        let alHandler = ALDBHandler.sharedInstance()
        guard let dbMessage: DB_Message = messageService.getMessageByKey(key, value: value) as? DB_Message else {
            print("Can't find message with key \(key) and value \(value)")
            return
        }
        dbMessage.filePath = filePath
        do {
            try alHandler?.managedObjectContext.save()
        } catch let error {
            print("Not saved due to error \(error)")
        }
    }
}
