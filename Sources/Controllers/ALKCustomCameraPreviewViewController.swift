//
//  ALKCustomCameraPreviewViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

final class ALKCustomCameraPreviewViewController: ALKBaseViewController {
    
    // MARK: - Variables and Types
    private var customCamDelegate:ALKCustomCameraProtocol!
    var image: UIImage!
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var imageView: UIImageView!

    @IBOutlet private weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    static func instance(with image: UIImage) -> ALKCustomCameraPreviewViewController {
        let viewController: ALKCustomCameraPreviewViewController = UIStoryboard(storyboard: .camera).instantiateViewController()
        viewController.image = image
        
        return viewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = NSLocalizedString("SendPhoto", value: SystemMessage.LabelName.SendPhoto, comment: "")
    }

    required public init(configuration: ALKConfiguration) {
        super.init(configuration: configuration)
    }

    override func loadView() {
        super.loadView()
        self.validateEnvironment()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigation()
        self.updateMinZoomScaleForSize(size: view.bounds.size)
        self.updateConstraintsForSize(size: view.bounds.size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Method of class
    private func validateEnvironment() {
        guard let _ = self.image else {
            fatalError("Please use instance(_:) or set image")
        }
    }
    
    private func setupContent() {
        self.imageView.image = self.image
        self.imageView.sizeToFit()
        
        self.scrollView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
    }
    
    private func setupNavigation() {
        self.navigationItem.title = title
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        guard let navVC = self.navigationController else {return}
        navVC.navigationBar.shadowImage = UIImage()
        navVC.navigationBar.isTranslucent = true
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    private func updateConstraintsXY(xOffset: CGFloat,yOffset: CGFloat) {
        imageViewTopConstraint?.constant = yOffset
        imageViewBottomConstraint?.constant = yOffset
        
        imageViewLeadingConstraint?.constant = xOffset
        imageViewTrailingConstraint?.constant = xOffset
    }
    
    fileprivate func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        
        self.updateConstraintsXY(xOffset: xOffset, yOffset: yOffset)
    }
    
    @objc private func doubleTapped(tap: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: { [weak self, weak imageView] in
            guard let `self` = self else { return }
            guard let `imageView` = imageView else { return }
            
            let view = imageView
            
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
    
    func setSelectedImage(pickImage:UIImage,camDelegate:ALKCustomCameraProtocol)
    {
        self.image = pickImage
        self.customCamDelegate = camDelegate
    }
    

    @IBAction private func sendPhotoPress(_ sender: Any) {
        self.navigationController?.dismiss(animated: false, completion: {
            self.customCamDelegate.customCameraDidTakePicture(cropedImage:self.image
            )
        })
    }
    @IBAction private func close(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: false)
    }
}

extension ALKCustomCameraPreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
        view.layoutIfNeeded()
    }
}
