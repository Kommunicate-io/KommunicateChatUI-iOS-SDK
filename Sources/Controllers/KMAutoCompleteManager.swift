//
//  KMAutoCompleteManager.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh on 16/09/19.
//

import UIKit
#if canImport(RichMessageKit)
    import RichMessageKit
#endif

public protocol KMAutoCompletionDelegate: AnyObject {
    func didMatch(prefix: String, message: String, updated: Bool)
    func sendMessage(content : String)
}

public protocol KMAutoCompletionItemCell: UITableViewCell {
    func updateView(item: KMAutoCompleteItem)
}

/// An autocomplete manager that is used for registering prefixes,
/// finding prefixes in user text and showing autocomplete suggestions.
public class KMAutoCompleteManager: NSObject {
    public let autocompletionView: UITableView
    public let textView: ALKChatBarTextView
    public weak var autocompletionDelegate: KMAutoCompletionDelegate?
    public var items = [KMAutoCompleteItem]()
    public var isAutoSuggestion: Bool = false

    // Prefix and entered word with its range in the text.
    typealias Selection = (
        prefix: String,
        range: NSRange,
        word: String
    )

    var selection: Selection? {
        didSet {
            if selection == nil {
                items = []
            }
        }
    }

    fileprivate var autoCompletionViewHeightConstraint: NSLayoutConstraint?
    private var autocompletionPrefixes: Set<String> = []
    private var prefixConfigurations: [String: KMAutoCompleteItemConfiguration] = [:]
    private var prefixCells: [String: KMAutoCompletionItemCell.Type] = [:]

    public init(
        textView: ALKChatBarTextView,
        tableview: UITableView
    ) {
        self.textView = textView
        autocompletionView = tableview
        super.init()
        self.autocompletionView.accessibilityIdentifier = "KMAutoCompletionTableView"
        self.textView.add(delegate: self)
        autocompletionView.dataSource = self
        autocompletionView.delegate = self
        autoCompletionViewHeightConstraint = autocompletionView.heightAnchor.constraint(equalToConstant: 0)
        autoCompletionViewHeightConstraint?.isActive = true
        autocompletionView.register(DefaultAutoCompleteCell.self)
    }

    public func registerPrefix<T: KMAutoCompletionItemCell>(
        prefix: String,
        configuration: KMAutoCompleteItemConfiguration = KMAutoCompleteItemConfiguration(),
        cellType: T.Type
    ) {
        autocompletionPrefixes.insert(prefix)
        prefixConfigurations[prefix] = configuration
        prefixCells[prefix] = cellType
        if cellType != DefaultAutoCompleteCell.self {
            autocompletionView.register(cellType)
        }
    }
    
    public func registerWithoutPrefix<T: KMAutoCompletionItemCell>(
        configuration: KMAutoCompleteItemConfiguration = KMAutoCompleteItemConfiguration(),
        cellType: T.Type
    ) {
        if cellType != DefaultAutoCompleteCell.self {
            autocompletionView.register(cellType)
            isAutoSuggestion = true
        }
    }

    public func reloadAutoCompletionView() {
        autocompletionView.reloadData()
    }

    public func hide(_ flag: Bool) {
        if flag {
            autoCompletionViewHeightConstraint?.constant = 0
        } else {
            let contentHeight = autocompletionView.contentSize.height

            let bottomPadding: CGFloat = contentHeight > 0 ? 25 : 0
            let maxheight: CGFloat = 200
            autoCompletionViewHeightConstraint?.constant = contentHeight < maxheight ? contentHeight + bottomPadding : maxheight
        }
    }

    public func cancelAndHide() {
        selection = nil
        hide(true)
    }

    func insert(item: KMAutoCompleteItem, at insertionRange: NSRange, replace selection: Selection) {
        
        if let supportsRichMessage = item.supportsRichMessage,
           supportsRichMessage {
            self.autocompletionDelegate?.sendMessage(content: item.content)
            textView.text = ""
            return
        }
        
        let defaultAttributes = textView.typingAttributes
        var newAttributes = defaultAttributes
        let configuration = prefixConfigurations[selection.prefix] ?? KMAutoCompleteItemConfiguration()
        if let style = configuration.textStyle {
            // pass prefix attributes for the range and override old value if present
            newAttributes.merge(style.toAttributes) { $1 }
        }
        if !configuration.allowEditingAutocompleteText {
            newAttributes[KMAutoCompleteItem.attributesKey] = selection.prefix + item.key
        }

        let prefix = configuration.insertWithPrefix ? selection.prefix : ""
        let insertionItemString = NSAttributedString(
            string: prefix + item.content,
            attributes: newAttributes
        )
        var insertionRange = insertionRange
        if !configuration.insertWithPrefix {
            insertionRange = NSRange(
                location: insertionRange.location - prefix.utf16.count,
                length: insertionRange.length + prefix.utf16.count
            )
        }
        let newAttributedText = textView.attributedText.replacingCharacters(
            in: insertionRange,
            with: insertionItemString
        )
        if configuration.addSpaceAfterInserting {
            newAttributedText.append(NSAttributedString(string: " ", attributes: defaultAttributes))
        }
        textView.attributedText = newAttributedText
    }
}

extension KMAutoCompleteManager: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText _: String
    ) -> Bool {
        guard textView.text != nil else {
            return true
        }

        // Check if deleting an autocomplete item, if yes then
        // remove full item in one go and clear the attributes
        //
        // range.length == 1: Remove single character
        // range.lowerBound < textView.selectedRange.lowerBound: Ignore trying to delete
        //      the substring if the user is already doing so
        if range.length == 1, range.lowerBound < textView.selectedRange.lowerBound {
            // Backspace/removing text
            let attribute = textView.attributedText
                .attributes(at: range.lowerBound, longestEffectiveRange: nil, in: range)
                .filter { $0.key == KMAutoCompleteItem.attributesKey }

            if let isAutocomplete = attribute[KMAutoCompleteItem.attributesKey] as? String, !isAutocomplete.isEmpty {
                // Remove the autocompleted substring
                let lowerRange = NSRange(location: 0, length: range.location + 1)
                textView.attributedText.enumerateAttribute(KMAutoCompleteItem.attributesKey, in: lowerRange, options: .reverse, using: { _, range, stop in

                    // Only delete the first found range
                    defer { stop.pointee = true }

                    let emptyString = NSAttributedString(string: "", attributes: textView.typingAttributes)
                    textView.attributedText = textView.attributedText.replacingCharacters(in: range, with: emptyString)
                    textView.selectedRange = NSRange(location: range.location, length: 0)
                })
            }
        }
        return true
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        if(isAutoSuggestion){
            guard let result = textView.find(prefixes: [""]) else{
                cancelAndHide()
                return
            }
            selection = (result.prefix, result.range, String(result.word.dropFirst(result.prefix.count)))
            autocompletionDelegate?.didMatch(prefix: "", message: String(textView.text), updated: false)
        } else {
            guard let result = textView.find(prefixes: autocompletionPrefixes) else {
                cancelAndHide()
                return
            }

            selection = (result.prefix, result.range, String(result.word.dropFirst(result.prefix.count)))
            // Call delegate and get items
            autocompletionDelegate?.didMatch(prefix: result.prefix, message: String(result.word.dropFirst(result.prefix.count)), updated: false)
        }
        }

    func cellType(forPrefix prefix: String) -> KMAutoCompletionItemCell.Type {
        return prefixCells[prefix] ?? DefaultAutoCompleteCell.self
    }
}

extension Style {
    var toAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: text,
            .backgroundColor: background,
            .font: font,
        ]
    }
}
