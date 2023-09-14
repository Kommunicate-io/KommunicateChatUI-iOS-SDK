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
        if message.autoSuggestionData == nil {
            message.autoSuggestionData = message.metadata[AUTO_SUGGESTION_TYPE_MESSAGE] as? String
        }
        guard let jsonData = message.autoSuggestionData else { return }
        let data = convertToDictionary(text: jsonData)
        guard let placeholderValue = data?["placeholder"] as? String else{ return }
        chatBar.placeHolder.text = placeholderValue
        if let suggestion = data?["source"] as? [String] {
            suggestionArray = suggestion
        } else if let suggestion = data?["source"] as? [[String : Any]] {
            suggestionDict = suggestion
        } else if let sourceDictionary = data?["source"] as? [String: Any], let url = sourceDictionary["url"] as? String {
            autoSuggestionApi = url
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
    
    func fetchData(from url: String, message check: String) {
        let searchURL: String = url + check.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: searchURL) else {
            print("Invalid URL recived in AutoSuggestion")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Error in Api comming from AutoSuggestion: \(error)")
                return
            }
            guard let data = data, let dataString = String(data: data, encoding: .utf8), let jsonData = dataString.data(using: .utf8) else {
                print("Invalid data recived form Api in AutoSuggestion")
                return
            }
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any], let dataArray = jsonObject["data"] as? [[String: Any]] {
                    self.suggestionDict = dataArray
                }
            } catch {
                print("Error parsing JSON data from AutoSuggestion: \(error)")
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
