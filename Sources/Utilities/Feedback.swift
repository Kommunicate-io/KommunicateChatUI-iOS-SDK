//
//  Feedback.swift
//  ApplozicSwift
//
//  Created by Kirti S on 12/31/21.
//

import Foundation
import UIKit

class Feedback : Localizable {
    
    var configuration = ALKConfiguration()
    
    func getRatingIconFor(rating : Int) -> UIImage? {
        var imageName = String()
        switch rating {
        case 1:
            imageName = localizedString(forKey: "SadIcon", withDefaultValue: SystemMessage.Feedback.sadIcon, fileName: configuration.localizedStringFileName)
        case 5:
            imageName = localizedString(forKey: "ConfusedIcon", withDefaultValue: SystemMessage.Feedback.confusedIcon, fileName: configuration.localizedStringFileName)
        case 10:
            imageName = localizedString(forKey: "HappyIcon", withDefaultValue: SystemMessage.Feedback.happyIcon, fileName: configuration.localizedStringFileName)
        default:
            print("incorrect data")
        }
        guard let ratingImage = UIImage(named: imageName, in: Bundle.applozic, compatibleWith: nil) else { return nil }
        return ratingImage
        
    }
}
