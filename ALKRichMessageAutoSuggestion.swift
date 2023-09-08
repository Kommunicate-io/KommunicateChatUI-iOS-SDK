//
//  ALKRichMessageAutoSuggestion.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Abhijeet Ranjan  on 07/09/23.
//

import UIKit
import KommunicateCore_iOS_SDK

extension ALKConversationViewController {
    public func setupAutoSuggestion(_ message: ALMessage) {
        guard let jsonData = message.autoSuggestionData else { return }
        let data = convertToDictionary(text: jsonData)
        guard let placeholderValue = data?["placeholder"] as? String else{ return }
        chatBar.placeHolder.text = placeholderValue
        if let suggestion = data?["source"] as? [String] {
            suggestionArray = suggestion
        } else if let suggestion = data?["source"] as? [[String : Any]] {
            suggestionDict = suggestion
        } else if let sourceDictionary = data?["source"] as? [String: Any], let url = sourceDictionary["url"] as? String {
            fetchData(from: url)
        }
        autoSuggestionView.isHidden = false
        isAutoSuggestionRichMessage = true
        self.autoSuggestionManager.registerWithoutPrefix(cellType: QuickReplyItemCell.self)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func fetchData(from url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data, let dataString = String(data: data, encoding: .utf8), let jsonData = dataString.data(using: .utf8) else {
                print("Invalid data")
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any], let dataArray = jsonObject["data"] as? [[String: Any]] {
                    self.suggestionDict = dataArray
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
}

class QuickReplyItemCell: UITableViewCell {


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension QuickReplyItemCell: AutoCompletionItemCell {
    func updateView(item: AutoCompleteItem) {
        textLabel?.text = "\(item.content)"
    }
}
