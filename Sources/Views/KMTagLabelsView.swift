//
//  KMTagLabelsView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 21/11/22.
//

import Foundation

class KMTagLabelsView: UIView {
    // Struct to store TagParameters
    struct TagParameters {
        public let height: CGFloat
        public let spacingX: CGFloat
        public let spacingY: CGFloat

        public init(height: CGFloat, spacingX: CGFloat, spacingY: CGFloat) {
            self.height = height
            self.spacingX = spacingX
            self.spacingY = spacingY
        }
    }

    var tagNames: [String] = [] {
        didSet {
            addTagLabels()
        }
    }

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
        self.subviews.forEach({ $0.removeFromSuperview() })
        for tag in tagNames {
            let view = KMTagView(title: tag)
            addSubview(view)
        }

    }
    let tagParameters = TagParameters(height: 30, spacingX: 8, spacingY: 8)
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
                currentOriginY += tagParameters.height + tagParameters.spacingY
            }
            
            // set the btn frame origin
            label.frame.origin.x = currentOriginX
            label.frame.origin.y = currentOriginY
            
            // increment current X by btn width + spacing
            currentOriginX += label.frame.width + tagParameters.spacingX
            
        }
        
        // update intrinsic height
        intrinsicHeight = currentOriginY + tagParameters.height
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
