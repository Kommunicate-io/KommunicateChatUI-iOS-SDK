//
//  UIImage+Extension.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    func toRadians() -> CGFloat {
        return CGFloat(self * .pi / 180.0)
    }
}

extension UIImage {
    
    
    convenience init?(color: Color.Text, alpha: CGFloat = 1.0, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        UIColor.color(color).withAlphaComponent(alpha).setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func resizeNotMoreThan(_ maximumSize: CGSize, aspectRatio: Bool) -> UIImage {
        let imageSize = self.size
        var newImage: UIImage!
        
        if maximumSize.width < imageSize.width || maximumSize.height < imageSize.height  {
            let (newSize, _) = CGSize.getSizeAndScaleNotMoreThan(imageSize, maximumSize: maximumSize, aspectRatio: aspectRatio)
            
            autoreleasepool{
                let rect = CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height)
                UIGraphicsBeginImageContext(rect.size)
                self.draw(in: rect)
                newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            return newImage
        }
        
        return self
    }
    
    func rotated(by degrees: Double, flipped: Bool = false) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: rect.size)
            
            return renderer.image { renderContext in
                renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
                renderContext.cgContext.rotate(by: degrees.toRadians())
                renderContext.cgContext.scaleBy(x: flipped ? -1.0 : 1.0, y: -1.0)
                
                let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
                renderContext.cgContext.draw(cgImage, in: drawRect)
            }
        } else {
            // Fallback on earlier versions
            return imageRotatedByDegrees(oldImage: self, deg: CGFloat(degrees))
        }
    }
    
    
    private func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        let size = oldImage.size
        
        UIGraphicsBeginImageContext(size)
        
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(Double.pi / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        
        let origin = CGPoint(x: -size.width / 2, y: -size.width / 2)
        
        bitmap.draw(oldImage.cgImage!, in: CGRect(origin: origin, size: size))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
