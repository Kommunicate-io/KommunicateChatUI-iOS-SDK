//
//  RatingHelper.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/04/22.
//

import Foundation
class RatingHelper : Localizable {

     var configuration = ALKConfiguration()

     func getRatingIconFor(rating : Int) -> UIImage? {
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
         guard let ratingImage = UIImage(named: imageName, in: Bundle.applozic, compatibleWith: nil) else { return nil }
         return ratingImage

     }
 }
