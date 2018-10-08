//
//  ALKPreviewImageViewModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation

final class ALKPreviewImageViewModel: NSObject, Localizable {
    
    var configuration: ALKConfiguration!
    
    var imageUrl: URL
    private var savingImagesuccessBlock: (() -> ())?
    private var savingImagefailBlock: ((Error) -> ())?

    fileprivate var downloadImageSuccessBlock: (() -> ())?
    fileprivate var downloadImageFailBlock: ((String) -> ())?

    fileprivate lazy var loadingFailErrorMessage: String = {
        let text = localizedString(forKey: "DownloadOriginalImageFail", withDefaultValue: SystemMessage.Warning.DownloadOriginalImageFail, config: configuration)
        return text
    }()

    init(imageUrl: URL, configuration: ALKConfiguration) {
        self.configuration = configuration
        self.imageUrl = imageUrl
    }


    func saveImage(image: UIImage?, successBlock: @escaping () -> (), failBlock: @escaping (Error) -> ()) {

        self.savingImagesuccessBlock   = successBlock
        self.savingImagefailBlock      = failBlock

        guard let image = image else {
            failBlock(NSError(domain: "IMAGE_NOT_AVAILABLE", code: 0 , userInfo: nil))
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(ALKPreviewImageViewModel.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error, let failBlock = savingImagefailBlock {
            failBlock(error)
        } else if let successBlock = savingImagesuccessBlock {
            successBlock()
        }
    }}
