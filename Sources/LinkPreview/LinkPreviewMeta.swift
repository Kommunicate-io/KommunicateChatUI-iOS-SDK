import Foundation

class LinkPreviewMeta {
    var title: String?
    var description: String?
    var image: String?
    var icon: String?
    var url: URL

    init(url: URL) {
        self.url = url
    }
}

extension LinkPreviewMeta {
    enum Key: String {
        case url
        case title
        case description
        case image
        case icon
    }

    func set(_ value: Any, for key: Key) {
        switch key {
        case Key.url:
            if let value = value as? URL { url = value }
        case Key.title:
            if let value = value as? String { title = value }
        case Key.description:
            if let value = value as? String { description = value }
        case Key.image:
            if let value = value as? String { image = value }
        case Key.icon:
            if let value = value as? String { icon = value }
        }
    }

    func value(for key: Key) -> Any? {
        switch key {
        case Key.url:
            return url
        case Key.title:
            return title
        case Key.description:
            return description
        case Key.image:
            return image
        case Key.icon:
            return icon
        }
    }

    func getBaseURl(url: String) -> String {
        if url.isEmpty {
            return ""
        }
        let finalUrl = url.replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
        return String(finalUrl.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)[0])
    }
}
