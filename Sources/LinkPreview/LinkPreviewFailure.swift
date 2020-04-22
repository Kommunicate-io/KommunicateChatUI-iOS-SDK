import Foundation

enum LinkPreviewFailure: Error {
    case noURLFound
    case invalidURL
    case cannotBeOpened
    case parseError
}
