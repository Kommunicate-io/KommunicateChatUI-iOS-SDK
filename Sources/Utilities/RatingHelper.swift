//
//  RatingHelper.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/04/22.
//

import Foundation
import UIKit

class RatingHelper: Localizable {

     var configuration = ALKConfiguration()

     func getRatingIconFor(rating: Int) -> UIImage? {
         var imageName = String()
         switch rating {
         case 1:
             imageName = "sadEmoji"
         case 5:
             imageName = "confusedEmoji"
         case 10:
             imageName = "happyEmoji"
         default:
             print("incorrect data")
         }
         guard let ratingImage = UIImage(named: imageName, in: Bundle.km, compatibleWith: nil) else { return nil }
         return ratingImage

     }
    
    func getRatingIconForFiveStar(rating: Int) -> UIImage? {
        var imageName = String()
        switch rating {
        case 1:
            imageName = "rating_star_filled"
        case 2:
            imageName = "rating_star_filled_two"
        case 3:
            imageName = "rating_star_filled_three"
        case 4:
            imageName = "rating_star_filled_four"
        case 5:
            imageName = "rating_star_filled_five"
        default:
            print("incorrect data")
        }
        guard let ratingImage = UIImage(named: imageName, in: Bundle.km, compatibleWith: nil) else { return nil }
        return ratingImage
    }
    
 }
