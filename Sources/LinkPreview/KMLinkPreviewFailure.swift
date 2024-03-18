import Foundation

enum KMLinkPreviewFailure: Error {
    case noURLFound
    case invalidURL
    case cannotBeOpened
    case parseError
}
