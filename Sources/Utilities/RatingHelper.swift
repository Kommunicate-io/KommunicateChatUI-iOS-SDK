//
//  RatingHelper.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/04/22.
//

import Foundation
import UIKit

class RatingHelper : Localizable {

     var configuration = ALKConfiguration()

     func getRatingIconFor(rating : Int) -> UIImage? {
         var imageName = String()
         switch rating {
         case 2:
             imageName = "rating_star_filled"
         case 4:
             imageName = "rating_star_filled_two"
         case 6:
             imageName = "rating_star_filled_three"
         case 8:
             imageName = "rating_star_filled_four"
         case 10:
             imageName = "rating_star_filled_five"
         default:
             print("incorrect data")
         }
         guard let ratingImage = UIImage(named: imageName, in: Bundle.km, compatibleWith: nil) else { return nil }
         return ratingImage

     }
 }
