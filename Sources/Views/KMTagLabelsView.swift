//
//  KMTagLabelsView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/11/22.
//

import Foundation

class KMTagLabelsView: UIView {

    var tagNames: [String] = [] {
        didSet {
            addTagLabels()
        }
    }
    
    let tagHeight:CGFloat = 30
    let tagPadding: CGFloat = 16
    let tagSpacingX: CGFloat = 8
    let tagSpacingY: CGFloat = 8

    var intrinsicHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() -> Void {
    }

    func addTagLabels() -> Void {
        // if we already have tag labels
        //  remove any excess (e.g. we had 5 tags, new set is only 3)
        while self.subviews.count > tagNames.count {
            self.subviews.forEach({ $0.removeFromSuperview() })
        }
                
        for tag in tagNames {
            let view = KMTagView(title: tag)
            addSubview(view)
        }

    }
    
    func displayTagLabels() {
        
        var currentOriginX: CGFloat = 0
        var currentOriginY: CGFloat = 0
        // if therse is no tag, set the height of the taglabel view to 0
        if tagNames.isEmpty {
            intrinsicHeight = 0
            invalidateIntrinsicContentSize()
            return
        }

        // for each label in the array
        self.subviews.forEach { v in
            
            guard let label = v as? KMTagView else {
                fatalError("non-KMTagView subview found!")
            }

            // if current X + label width will be greater than container view width
            //  "move to next row"
            if currentOriginX + label.frame.width > bounds.width {
                currentOriginX = 0
                currentOriginY += tagHeight + tagSpacingY
            }
            
            // set the btn frame origin
            label.frame.origin.x = currentOriginX
            label.frame.origin.y = currentOriginY
            
            // increment current X by btn width + spacing
            currentOriginX += label.frame.width + tagSpacingX
            
        }
        
        // update intrinsic height
        intrinsicHeight = currentOriginY + tagHeight
        invalidateIntrinsicContentSize()
        
    }

    // allow this view to set its own intrinsic height
    override var intrinsicContentSize: CGSize {
        var sz = super.intrinsicContentSize
        sz.height = intrinsicHeight
        return sz
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayTagLabels()
    }
    
}
