//
//  ALKConversationViewController+Giphy.swift
//  ApplozicSwift
//
//  Created by Sunil on 24/05/21.
//

import Foundation
import GiphyUISDK

extension ALKConversationViewController: GiphyDelegate {
    public func didDismiss(controller _: GiphyViewController?) {
        GPHCache.shared.clear()
    }

    public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        let giphyDownloadURL = media.images?.downsized?.gifUrl ?? media.images?.preview?.gifUrl ?? media.images?.looping?.gifUrl

        guard let urlString = giphyDownloadURL,
              let giphyURL = URL(string: urlString)
        else {
            giphyViewController.dismiss(animated: true)
            return
        }
        let infoMessage = localizedString(forKey: "ExportLoadingIndicatorTextForGiphy", withDefaultValue: SystemMessage.Warning.exportLoadingIndicatorTextForGiphy, fileName: configuration.localizedStringFileName)

        giphyViewController.displayIPActivityAlert(title: infoMessage)

        let task = URLSession.shared.downloadTask(with: giphyURL
        ) { url, _, error in

            guard error == nil,
                  let actualURL = url,
                  let data = try? Data(contentsOf: actualURL)
            else {
                DispatchQueue.main.async {
                    giphyViewController.dismissIPActivityAlert {
                        giphyViewController.dismiss(animated: true)
                    }
                }
                return
            }

            DispatchQueue.main.async {
                giphyViewController.dismissIPActivityAlert {
                    giphyViewController.dismiss(animated: true) {
                        do {
                            let fileName = "GIF-\(Date().timeIntervalSince1970 * 1000).gif"

                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let pathURL = documentsURL.appendingPathComponent(fileName)
                            try data.write(to: pathURL)

                            let (message, indexPath) = self.viewModel.sendFile(
                                at: pathURL,
                                fileName: fileName,
                                metadata: self.configuration.messageMetadata
                            )

                            guard message != nil, let newIndexPath = indexPath else { return }

                            self.tableView.beginUpdates()
                            self.tableView.insertSections(IndexSet(integer: newIndexPath.section), with: .automatic)
                            self.tableView.endUpdates()
                            self.tableView.scrollToBottom(animated: false)

                            guard let cell = self.tableView.cellForRow(at: newIndexPath) as? ALKPhotoCell else { return }

                            self.viewModel.uploadImage(view: cell, indexPath: newIndexPath)
                        } catch {
                            print("Error in exporting giphy: ", error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
