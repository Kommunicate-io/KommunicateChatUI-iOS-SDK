//
//  KMRichMessageSASTokenHelper.swift
//  KommunicateChatUI-iOS-SDK
//

import Foundation

enum KMRichMessageSASTokenHelper {
    static func appendSASTokenIfNeeded(to urlString: String) -> String {
        guard !urlString.isEmpty,
              let token = normalizedSASToken(),
              !token.isEmpty,
              !urlString.contains(token)
        else {
            return urlString
        }

        let separator = urlString.contains("?") ? "&" : "?"
        return urlString + separator + token
    }

    private static func normalizedSASToken() -> String? {
        guard let token = KMChatAppSettingsUserDefaults().getAppSettings()?.sasT?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !token.isEmpty
        else {
            return nil
        }

        return token.replacingOccurrences(of: "+", with: "%2B")
    }
}
