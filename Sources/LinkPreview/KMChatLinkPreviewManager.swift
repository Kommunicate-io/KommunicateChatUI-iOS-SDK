import Foundation

class KMChatLinkPreviewManager: NSObject, URLSessionDelegate {
    enum TextMinimumLength {
        static let title: Int = 15
        static let decription: Int = 100
    }

    private static let urlCache = NSCache<NSString, AnyObject>()
    private let workBckQueue: DispatchQueue
    private let responseMainQueue: DispatchQueue

    init(workBckQueue: DispatchQueue = DispatchQueue.global(qos: .background),
         responseMainQueue: DispatchQueue = DispatchQueue.main) {
        self.workBckQueue = workBckQueue
        self.responseMainQueue = responseMainQueue
    }

    func makePreview(from text: String, identifier: String, _ completion: @escaping (Result<(KMLinkPreviewMeta, URL), KMLinkPreviewFailure>) -> Void) {
        guard let url = KMChatLinkPreviewManager.extractURLAndAddInCache(from: text, identifier: identifier) else {
            responseMainQueue.async {
                completion(.failure(.noURLFound))
            }
            return
        }

        workBckQueue.async {
            guard let url = url.scheme == "http" || url.scheme == "https" ? url : URL(string: "http://\(url)") else {
                self.responseMainQueue.async {
                    completion(.failure(.invalidURL))
                }
                return
            }

            let request = URLRequest(url: url)
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            session.dataTask(with: request) { [weak self] data, response, error in
                guard let weakSelf = self, error == nil else {
                    self?.responseMainQueue.async {
                        completion(.failure(.cannotBeOpened))
                    }
                    return
                }

                var linkPreview: KMLinkPreviewMeta?

                if let data = data, let urlResponse = response,
                   let encoding = urlResponse.textEncodingName,
                   let source = NSString(data: data, encoding: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encoding as CFString))) {
                    linkPreview = weakSelf.parseHtmlAndUpdateLinkPreviewMeta(text: source as String, baseUrl: url.absoluteString)

                } else {
                    guard let data = data, response != nil else {
                        return
                    }
                    let htmlString = String(data: data, encoding: .utf8)
                    linkPreview = weakSelf.parseHtmlAndUpdateLinkPreviewMeta(text: htmlString, baseUrl: url.absoluteString)
                }
                guard let linkPreviewData = linkPreview else {
                    weakSelf.responseMainQueue.async {
                        completion(.failure(.parseError))
                    }
                    return
                }
                KMLinkURLCache.addLink(linkPreviewData, for: linkPreviewData.url.absoluteString)
                weakSelf.responseMainQueue.async {
                    completion(.success((linkPreviewData, url)))
                }

            }.resume()
        }
    }

    // MARK: - Private helpers

    private func cleanUnwantedTags(from html: String) -> String {
        return html.deleteTagByPattern(KMLinkPreviewRegex.Pattern.InLine.style)
            .deleteTagByPattern(KMLinkPreviewRegex.Pattern.InLine.script)
            .deleteTagByPattern(KMLinkPreviewRegex.Pattern.Script.tag)
            .deleteTagByPattern(KMLinkPreviewRegex.Pattern.Comment.tag)
    }

    private func parseHtmlAndUpdateLinkPreviewMeta(text: String?, baseUrl: String) -> KMLinkPreviewMeta? {
        guard let text = text, let url = URL(string: baseUrl) else { return nil }
        let cleanHtml = cleanUnwantedTags(from: text)

        var result = KMLinkPreviewMeta(url: url)
        result.icon = parseIcon(in: text, baseUrl: baseUrl)
        var linkFreeHtml = cleanHtml.deleteTagByPattern(KMLinkPreviewRegex.Pattern.Link.tag)

        parseMetaTags(in: &linkFreeHtml, result: &result)
        parseTitle(&linkFreeHtml, result: &result)
        parseDescription(linkFreeHtml, result: &result)
        return result
    }

    private func parseMetaTags(in text: inout String, result: inout KMLinkPreviewMeta) {
        let tags = KMLinkPreviewRegex.pregMatchAll(text, pattern: KMLinkPreviewRegex.Pattern.Meta.tag, index: 1)

        let possibleTags: [String] = [
            KMLinkPreviewMeta.Key.title.rawValue,
            KMLinkPreviewMeta.Key.description.rawValue,
            KMLinkPreviewMeta.Key.image.rawValue
        ]
        for metatag in tags {
            for tag in possibleTags {
                if metatag.range(of: "property=\"og:\(tag)") != nil ||
                    metatag.range(of: "property='og:\(tag)") != nil ||
                    metatag.range(of: "name=\"twitter:\(tag)") != nil ||
                    metatag.range(of: "name='twitter:\(tag)") != nil ||
                    metatag.range(of: "name=\"\(tag)") != nil ||
                    metatag.range(of: "name='\(tag)") != nil ||
                    metatag.range(of: "itemprop=\"\(tag)") != nil ||
                    metatag.range(of: "itemprop='\(tag)") != nil {
                    if let key = KMLinkPreviewMeta.Key(rawValue: tag),
                       result.value(for: key) == nil {
                        if let value = KMLinkPreviewRegex.pregMatchFirst(metatag, pattern: KMLinkPreviewRegex.Pattern.Meta.content, index: 2) {
                            let value = value.decodedHtml.extendedTrim
                            if tag == "image" {
                                let value = handleImagePrefixAndSuffix(value, baseUrl: result.url.absoluteString)
                                if KMLinkPreviewRegex.isMatchFound(value, regex: KMLinkPreviewRegex.Pattern.Image.type) { result.set(value, for: key) }
                            } else {
                                result.set(value, for: key)
                            }
                        }
                    }
                }
            }
        }
    }

    private func parseIcon(in text: String, baseUrl: String) -> String? {
        let links = KMLinkPreviewRegex.pregMatchAll(text, pattern: KMLinkPreviewRegex.Pattern.Link.tag, index: 1)
        // swiftlint:disable:next opening_brace
        let filters = [{ (link: String) -> Bool
            in link.range(of: "apple-touch") != nil
        }, { (link: String) -> Bool
            in link.range(of: "shortcut") != nil
        }, { (link: String) -> Bool
            in link.range(of: "icon") != nil
        }]
        for filter in filters {
            guard let link = links.filter(filter).first else { continue }
            if let matches = KMLinkPreviewRegex.pregMatchFirst(link, pattern: KMLinkPreviewRegex.Pattern.Image.href, index: 1) {
                return handleImagePrefixAndSuffix(matches, baseUrl: baseUrl)
            }
        }
        return nil
    }

    private func parseTitle(_ htmlCode: inout String, result: inout KMLinkPreviewMeta) {
        let title = result.title
        if title == nil || title?.isEmpty ?? true {
            if let value = KMLinkPreviewRegex.pregMatchFirst(htmlCode, pattern: KMLinkPreviewRegex.Pattern.Title.tag, index: 2) {
                if value.isEmpty {
                    let data: String = getTagData(htmlCode, minimum: TextMinimumLength.title)
                    if !data.isEmpty {
                        result.title = data.decodedHtml.extendedTrim
                        htmlCode = htmlCode.replace(data, with: "")
                    }
                } else {
                    result.title = value.decodedHtml.extendedTrim
                }
            }
        }
    }

    private func parseDescription(_ htmlCode: String, result: inout KMLinkPreviewMeta) {
        let description = result.description

        if description == nil || description?.isEmpty ?? true {
            let value: String = getTagData(htmlCode, minimum: TextMinimumLength.decription)
            if !value.isEmpty {
                result.description = value.decodedHtml.extendedTrim
            }
        }
    }

    private func handleImagePrefixAndSuffix(_ image: String, baseUrl: String) -> String {
        var url = image
        if let index = image.firstIndex(of: "?") {
            url = String(image[..<index])
        }
        guard !url.starts(with: "http") else { return url }
        if url.starts(with: "//") {
            return "http:" + url
        } else if url.starts(with: "/") {
            if baseUrl.starts(with: "http://") || baseUrl.starts(with: "https://") {
                return baseUrl + url
            }
            return "http://" + baseUrl + url
        } else {
            return url
        }
    }

    /// Returns the very first url encountered in the text.
    /// - Parameter text: text from which url is to be search
    /// - Parameter identifier: Message identifier for cache
    class func extractURLAndAddInCache(from text: String?, identifier: String) -> URL? {
        guard let message = text else {
            return nil
        }

        guard let urlString = urlCache.object(forKey: identifier as NSString), let url = URL(string: urlString as! String) else {
            do {
                let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let range = NSRange(location: 0, length: message.utf16.count)
                let matches = detector.matches(in: message, options: [], range: range)
                
                let validURLs = matches.compactMap { result -> URL? in
                    guard result.resultType == .link, let url = result.url, url.scheme?.lowercased().starts(with: "http") == true else {
                        return nil
                    }
                    return url
                }

                guard let url = validURLs.first else {
                    return nil
                }

                urlCache.setObject(url.absoluteString as NSString, forKey: identifier as NSString)
                return url
            } catch {
                return nil
            }
        }
        return url
    }

    private func getTagData(_ content: String, minimum: Int) -> String {
        let paragraphTagData = getTagContent("p", content: content, minimum: minimum)

        if !paragraphTagData.isEmpty {
            return paragraphTagData
        } else {
            let devTagData = getTagContent("div", content: content, minimum: minimum)
            if !devTagData.isEmpty {
                return devTagData
            } else {
                let spanTagData = getTagContent("span", content: content, minimum: minimum)
                if !spanTagData.isEmpty {
                    return spanTagData
                }
            }
        }
        return ""
    }

    private func getTagContent(_ tag: String, content: String, minimum: Int) -> String {
        let pattern = KMLinkPreviewRegex.tagPattern(tag)

        let index = 2
        let rawMatches = KMLinkPreviewRegex.pregMatchAll(content, pattern: pattern, index: index)

        let matches = rawMatches.filter { $0.extendedTrim.deleteTagByPattern(KMLinkPreviewRegex.Pattern.Raw.tag).count >= minimum }
        var result = !matches.isEmpty ? matches[0] : ""

        if result.isEmpty {
            if let match = KMLinkPreviewRegex.pregMatchFirst(content, pattern: pattern, index: 2) {
                result = match.extendedTrim.deleteTagByPattern(KMLinkPreviewRegex.Pattern.Raw.tag)
            }
        }
        return result
    }
}

extension String {
    func deleteTagByPattern(_ pattern: String) -> String {
        return replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
    }

    var extendedTrim: String {
        let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ").trim()
    }

    var decodedHtml: String {
        let encodedData = data(using: String.Encoding.utf8)!
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] =
            [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
            ]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            return attributedString.string

        } catch _ {
            return self
        }
    }

    func replace(_ search: String, with: String) -> String {
        let replaced: String = replacingOccurrences(of: search, with: with)
        return replaced.isEmpty ? self : replaced
    }
}
