import Foundation

class LinkPreviewRegex {
    enum Pattern {
        enum Image {
            static let type = "(.+?)\\.(gif|jpg|jpeg|png|bmp)$"
            static let href = ".*href=\"(.*?)\".*"
        }

        enum Title {
            static let tag = "<title(.*?)>(.*?)</title>"
        }

        enum Meta {
            static let tag = "<meta(.*?)>"
            static let content = "content=(\"(.*?)\")|('(.*?)')"
        }

        enum Raw {
            static let tag = "<[^>]+>"
        }

        enum InLine {
            static let style = "<style(.*?)>(.*?)</style>"
            static let script = "<script(.*?)>(.*?)</script>"
        }

        enum Link {
            static let tag = "<link(.*?)>"
        }

        enum Script {
            static let tag = "<script(.*?)>(.*?)</script>"
        }

        enum Comment {
            static let tag = "<!--(.*?)-->"
        }
    }

    // Check the regular expression
    static func isMatchFound(_ string: String, regex: String) -> Bool {
        return LinkPreviewRegex.pregMatchFirst(string, pattern: regex) != nil
    }

    // Match first occurrency
    static func pregMatchFirst(_ string: String, pattern: String, index: Int = 0) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(string.startIndex ..< string.endIndex, in: string)
            guard let match = regex.firstMatch(in: string, options: [], range: range) else {
                return nil
            }
            let result: [String] = LinkPreviewRegex.stringMatches([match], text: string, index: index)
            return result.isEmpty ? nil : result[0]
        } catch {
            return nil
        }
    }

    // Match all occurrencies
    static func pregMatchAll(_ string: String, pattern: String, index: Int = 0) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(string.startIndex ..< string.endIndex, in: string)
            let matches = regex.matches(in: string, options: [], range: range)
            return !matches.isEmpty ? LinkPreviewRegex.stringMatches(matches, text: string, index: index) : []
        } catch {
            return []
        }
    }

    // Extract matches from string
    static func stringMatches(_ results: [NSTextCheckingResult], text: String, index: Int = 0) -> [String] {
        return results.map {
            let range = $0.range(at: index)
            if text.count > range.location + range.length {
                return (text as NSString).substring(with: range)
            } else {
                return ""
            }
        }
    }

    // Return tag pattern
    // Creates this pattern :: <tagName ...>...</tagName>
    static func tagPattern(_ tag: String) -> String {
        return "<" + tag + "(.*?)>(.*?)</" + tag + ">"
    }
}
