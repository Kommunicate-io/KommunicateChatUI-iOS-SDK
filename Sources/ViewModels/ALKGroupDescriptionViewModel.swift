//
//  ALKGroupDescriptionViewModel.swift
//  ApplozicSwift
//
//  Created by Sunil on 14/04/21.
//

import ApplozicCore
import Foundation

// MARK: Group description View Model

struct ALKGroupDescriptionViewModel {
    enum GroupDescription {
        static let key = "AL_GROUP_DESCRIPTION"
    }

    let channelService = ALChannelService()
    let channelKey: NSNumber

    /// Update the group description
    /// - Parameters:
    ///   - description: pass the description of group for updating the it.
    ///   - completion: returns result BOOL success in case of success or  error in case of any update failure.
    func updateGroupDescription(description: String?, completion: @escaping (Result<Bool, Error>) -> Void) {
        let channel = channelService.getChannelByKey(channelKey)
        let channelMetadata = channel?.metadata ?? NSMutableDictionary()
        // Handle the group Description remove case
        if let descriptionText = description, !descriptionText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            channelMetadata[GroupDescription.key] = description
        } else {
            channelMetadata[GroupDescription.key] = ""
        }

        channelService.updateChannelMetaData(channelKey,
                                             orClientChannelKey: nil,
                                             metadata: channelMetadata) { error in

            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(true))
        }
    }

    /// To get the current group description stored in data base.
    /// - Returns: returns description string.
    func groupDescription() -> String? {
        let channel = channelService.getChannelByKey(channelKey)
        let channelMetadata = channel?.metadata ?? NSMutableDictionary()
        return channelMetadata.value(forKey: GroupDescription.key) as? String
    }
}
