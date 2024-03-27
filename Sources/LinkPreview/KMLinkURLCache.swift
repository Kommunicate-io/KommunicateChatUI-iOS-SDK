import Foundation

class KMLinkURLCache {
    private static let cache = NSCache<NSString, KMLinkPreviewMeta>()

    static func getLink(for url: String) -> KMLinkPreviewMeta? {
        return cache.object(forKey: url as NSString)
    }

    static func addLink(_ link: KMLinkPreviewMeta, for url: String) {
        cache.setObject(link, forKey: url as NSString)
    }
}
