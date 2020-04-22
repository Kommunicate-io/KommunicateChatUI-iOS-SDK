import Foundation

class LinkURLCache {
    private static let cache = NSCache<NSString, LinkPreviewMeta>()

    static func getLink(for url: String) -> LinkPreviewMeta? {
        return cache.object(forKey: url as NSString)
    }

    static func addLink(_ link: LinkPreviewMeta, for url: String) {
        cache.setObject(link, forKey: url as NSString)
    }
}
