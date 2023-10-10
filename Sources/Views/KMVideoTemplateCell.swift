//
//  KMVideoTemplateCell.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by sathyan elangovan on 07/09/23.
//

import Foundation
import AVKit
import Kingfisher
import KommunicateCore_iOS_SDK
import UIKit

#if canImport(RichMessageKit)
    import RichMessageKit
#endif

class KMVideoTemplateCell: ALKChatBaseCell<ALKMessageViewModel> {
   
    var videoTableview =  UITableView()
    
    public var playtapped: ((_ url: String) -> Void)?

    var messageModel : ALKMessageViewModel?
    
    private var template: [VideoTemplate]? {
        didSet {
           setUpTableView()
        }
    }

    var timeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()

    var fileSizeLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    var bubbleView: UIView = {
        let bv = UIView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        return bv
    }()

    private var frontView: ALKTappableView = {
        let view = ALKTappableView()
        view.alpha = 1.0
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    class func topPadding() -> CGFloat {
        return 12
    }

    class func bottomPadding() -> CGFloat {
        return 16
    }
        
    override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        guard let model = viewModel.videoTemplate() else {
            return 0
        }
        
        var heigh: CGFloat

        if viewModel.ratio < 1 {
            heigh = viewModel.ratio == 0 ? (width * 0.48) : ceil((width * 0.48) / viewModel.ratio)
        } else {
            heigh = ceil((width * 0.64) / viewModel.ratio)
        }
        heigh += 50.0
        return heigh * CGFloat(model.count)
    }

    override func update(viewModel: ALKMessageViewModel) {
        self.messageModel = viewModel
        self.template = viewModel.videoTemplate()
        timeLabel.text = viewModel.time
    }
    
    override func setupStyle() {
        super.setupStyle()

        timeLabel.setStyle(ALKMessageStyle.time)
    }

    override func setupViews() {
        super.setupViews()
        
        contentView.addViewsForAutolayout(views: [timeLabel, bubbleView, videoTableview])
        contentView.bringSubviewToFront(videoTableview)
        
        bubbleView.topAnchor.constraint(equalTo: videoTableview.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: videoTableview.bottomAnchor).isActive = true
        bubbleView.leftAnchor.constraint(equalTo: videoTableview.leftAnchor).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: videoTableview.rightAnchor).isActive = true
    }
    
    private func setUpTableView() {
        videoTableview.backgroundColor = .clear
        videoTableview.separatorStyle = .none
        videoTableview.allowsSelection = false
        videoTableview.isScrollEnabled = false
        videoTableview.delegate = self
        videoTableview.dataSource = self
        
        if #available(iOS 15.0, *) {  /// this is to remove the extra top padding form the cell
            videoTableview.sectionHeaderTopPadding = 0
        }
        videoTableview.register(KMVideoCell.self)
    }
}

extension KMVideoTemplateCell :  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return template?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KMVideoCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        guard let template = template else {
            return UITableViewCell() }
        cell.updateVideModel(model: template[indexPath.row])
        cell.tapped = { url in
            self.playtapped?(url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = messageModel else { return 0 }
        let heigh: CGFloat
        let width = UIScreen.main.bounds.width
        if model.ratio < 1 {
            heigh = model.ratio == 0 ? (width * 0.48) : ceil((width * 0.48) / model .ratio)
        } else {
            heigh = ceil((width * 0.64) / model.ratio)
        }
        return heigh
    }
}
