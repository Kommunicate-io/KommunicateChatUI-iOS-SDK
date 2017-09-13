//
//  ViewController.swift
//  TestScrollView
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

final class ALKPreviewImageViewController: UIViewController {
    
    // to be injected
    var viewModel: ALKPreviewImageViewModel?
    
    @IBOutlet private weak var fakeView: UIView!
    
    fileprivate let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: .zero)
        sv.backgroundColor = UIColor.clear
        sv.isUserInteractionEnabled = true
        sv.isScrollEnabled = true
        return sv
    }()

    
    fileprivate let imageView: UIImageView = {
        let mv = UIImageView(frame: .zero)
        mv.contentMode = .scaleAspectFit
        mv.backgroundColor = UIColor.clear
        mv.isUserInteractionEnabled = false
        return mv
    }()

    private weak var imageViewBottomConstraint: NSLayoutConstraint?
    private weak var imageViewTopConstraint: NSLayoutConstraint?
    private weak var imageViewTrailingConstraint: NSLayoutConstraint?
    private weak var imageViewLeadingConstraint: NSLayoutConstraint?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        DispatchQueue.main.async { [weak self] in
//            guard let weakSelf = self else { return }
//            MBProgressHUD.showAdded(to: weakSelf.fakeView, animated: true)
//        }
//        
//        viewModel?.prepareActualImage(successBlock: { [weak self] in
//            guard let weakSelf = self else { return }
//            
//            DispatchQueue.main.async {
//                weakSelf.setupView()
//                weakSelf.updateMinZoomScaleForSize(size: weakSelf.view.bounds.size)
//                weakSelf.updateConstraintsForSize(size: weakSelf.view.bounds.size)
//                
//                MBProgressHUD.hide(for: weakSelf.fakeView, animated: true)
//            }
//            
//            }, failBlock: { [weak self] (errorMessage)  in
//                guard let weakSelf = self else { return }
//                
//                DispatchQueue.main.async {
//                    MBProgressHUD.hide(for: weakSelf.fakeView, animated: true)
//                    
//                    weakSelf.view.makeToast(errorMessage, duration: 3.0, position: .center)
//                    weakSelf.perform(#selector(weakSelf.dismissPress(_:)), with: nil, afterDelay: 3)
//                }
//        })
    }
    
    
    private func setupNavigation() {
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        updateMinZoomScaleForSize(size: view.bounds.size)
        updateConstraintsForSize(size: view.bounds.size)
    }
    
    fileprivate func setupView() {
        guard let viewModel = viewModel else { return }
        
        scrollView.delegate = self
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(tap:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        imageView.kf.setImage(with: viewModel.imageUrl)
        imageView.sizeToFit()
        
        view.addViewsForAutolayout(views: [scrollView])
        scrollView.addViewsForAutolayout(views: [imageView])
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewTopConstraint?.isActive = true
        
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        imageViewBottomConstraint?.isActive = true
        
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewLeadingConstraint?.isActive = true
        
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        imageViewTrailingConstraint?.isActive = true
        
        view.layoutIfNeeded()
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale  = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale    = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    fileprivate func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        updateConstraintsXY(xOffset: xOffset, yOffset: yOffset)
    }
    
    fileprivate func updateConstraintsXY(xOffset: CGFloat,yOffset: CGFloat) {
        imageViewTopConstraint?.constant        = yOffset
        imageViewBottomConstraint?.constant     = yOffset
        
        imageViewLeadingConstraint?.constant    = xOffset
        imageViewTrailingConstraint?.constant   = xOffset
    }
    
    @IBAction private func dismissPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func downlaodImgPress(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        viewModel.saveImage(image: imageView.image, successBlock: {

            let photoAlbumSuccessTitleMsg = NSLocalizedString("PhotoAlbumSuccessTitle",value: SystemMessage.PhotoAlbum.SuccessTitle, comment: "")
            let photoAlbumSuccessMsg = NSLocalizedString("PhotoAlbumSuccess",value: SystemMessage.PhotoAlbum.Success, comment: "")
            let alert = UIAlertController(title: photoAlbumSuccessTitleMsg, message: photoAlbumSuccessMsg, preferredStyle: UIAlertControllerStyle.alert)
            let photoAlbumOkMsg = NSLocalizedString("PhotoAlbumOk",value: SystemMessage.PhotoAlbum.Ok, comment: "")
            alert.addAction(UIAlertAction(title: photoAlbumOkMsg, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }) { (error) in
            let photoAlbumFailureTitleMsg = NSLocalizedString("PhotoAlbumFailureTitle",value: SystemMessage.PhotoAlbum.FailureTitle, comment: "")
            let photoAlbumFailMsg = NSLocalizedString("PhotoAlbumFail",value: SystemMessage.PhotoAlbum.Fail, comment: "")
            let alert = UIAlertController(title: photoAlbumFailureTitleMsg, message: photoAlbumFailMsg, preferredStyle: UIAlertControllerStyle.alert)
            let photoAlbumOkMsg = NSLocalizedString("PhotoAlbumOk",value: SystemMessage.PhotoAlbum.Ok, comment: "")
            alert.addAction(UIAlertAction(title: photoAlbumOkMsg, style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func doubleTapped(tap: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            let view = self.imageView
            
            let viewFrame = view.frame
            
            let location = tap.location(in: view)
            let w = viewFrame.size.width/2.0
            let h = viewFrame.size.height/2.0
            
            let rect = CGRect(x: location.x - (w/2), y: location.y - (h/2), width: w, height: h)
            
            if self.scrollView.minimumZoomScale == self.scrollView.zoomScale {
                self.scrollView.zoom(to: rect, animated: false)
            } else {
                self.updateMinZoomScaleForSize(size: self.view.bounds.size)
            }
            
        }, completion: nil)
    }
    
    @objc private func singleTapped(tap: UITapGestureRecognizer) {
        if scrollView.minimumZoomScale == scrollView.zoomScale {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ALKPreviewImageViewController: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        updateConstraintsForSize(size: view.bounds.size)
        view.layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
