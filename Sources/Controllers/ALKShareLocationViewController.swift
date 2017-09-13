//
//  ALKShareLocationViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
//import GoogleMaps
import CoreLocation
import Kingfisher
import Applozic

protocol ALKShareLocationViewControllerDelegate: class {
//    func locationDidSelected(geocode: Geocode, image: UIImage)
}


final class ALKShareLocationViewController: ALKShareLocationBaseViewController {
    
//    fileprivate var pinCoordinate: CLLocationCoordinate2D?
//    
//    weak var delegate: ALKShareLocationViewControllerDelegate?
//    
//    // shareLocation
//    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
//    @IBOutlet private weak var shareLocationButton: UIButton!
//
//    @IBOutlet weak var pinImageView: UIImageView!
//    @IBOutlet weak var shareLocationImageView: UIImageView!
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let title = NSLocalizedString("ShareLocationTitle", value: "Share Location", comment: "")
//        self.navigationItem.title = title
//        self.shareLocationButton.setTitle(title, for: .normal)
//        
//        pinImageView.tintColor = UIColor(netHex: 0x0578FF)
//        shareLocationImageView.tintColor = UIColor(netHex: 0x0578FF)
//        self.mapView?.isMyLocationEnabled = true
//
//        //Location Manager code to fetch current location
//        self.locationManager.startUpdatingLocation()
//
//    }
//
//    fileprivate var isLoading: Bool = true {
//        willSet(newValue) {
//             if newValue {
//                shareLocationButton.isHidden = true
//                activityIndicatorView.startAnimating()
//            } else {
//                shareLocationButton.isHidden = false
//                activityIndicatorView.stopAnimating()
//            }
//        }
//    }
//    
//    private func reverseGeocode(position: CLLocationCoordinate2D,
//                                success: @escaping ([Geocode]) -> (),
//                                failure: @escaping (Error?) -> ()) {
//        
//        let request = ReverseGeoCodeRequest()
//        request.location = position
//
//        API.requestForItems(request: request) { (geocodes: [Geocode]?, isCache, error) in
//            
//            if error != nil {
//                failure(error)
//                return
//            }
//            
//            guard let geocodes = geocodes else {
//                failure(nil)
//                return
//            }
//            
//            success(geocodes)
//        }
//    }
//
//    private func createStaticMap(position: CLLocationCoordinate2D,
//                                success: @escaping (UIImage) -> (),
//                                failure: @escaping (Error?) -> ()) {
//        guard let apiKey = ALUserDefaultsHandler.getGoogleMapAPIKey() else { return }
//        var urlString: String? = "https://maps.googleapis.com/maps/api/staticmap?" +
//            "markers=color:red|size:mid|\(position.latitude),\(position.longitude)" +
//            "&zoom=15&size=237x102&maptype=roadmap&scale=2" +
//            "&key=\(apiKey)"
//        
//        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        
//        if let urlString = urlString, let url = URL(string: urlString) {
//            
//            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image: Image?, error: NSError?, cacheType: CacheType, url: URL?) in
//            
//
//                guard let image = image else {
//                    failure(error)
//                    return
//                }
//                success(image)
//            }
//        }
//    }
//
//    @IBAction func dismissTapped(_ sender: Any) {
//       self.dismiss(animated: true, completion: nil)
//    }
//    
//    @IBAction func shareLocationTapped(_ button: UIButton) {
//        
//        if isObserveMyLocation{
//            isLoading = true
//            
//            guard let _ = pinCoordinate else {
//                return
//            }
//            
//            guard let coor = pinCoordinate else {
//                isLoading = false
//                return
//            }
//            
//
//            var geocode: Geocode?
//            var locationImage: UIImage?
//            
//            let group = DispatchGroup()
//            group.enter()
//            group.enter()
//            
//            // get geocodes from googleAPI
//            reverseGeocode(position: coor, success: {(geocodes) in
//                geocode = geocodes.first
//                group.leave()
//                
//            }, failure: { [weak self]  (error) in
//                guard let weakSelf = self else {return}
//
//                group.leave()
//            })
//            
//            // get location image from googleAPI
//            createStaticMap(position: coor, success: { (image) in
//                locationImage = image
//                group.leave()
//                
//            }, failure: { (error) in
//                group.leave()
//            })
//            
//            // pass value by delegate and dismiss on this page.
//            group.notify(queue: DispatchQueue.main, execute: { [weak self] in
//                guard let strongSelf = self,
//                    let locationImage = locationImage,
//                    let geocode = geocode else {
//                        self?.isLoading = false
//                        return
//                }
//                
//                geocode.location = coor
//                
//                strongSelf.delegate?.locationDidSelected(geocode: geocode, image: locationImage)
//                strongSelf.dismiss(animated: true, completion: {
//                    self?.isLoading = false
//                })
//            })
//        }
//    }
}


// MARK: GMSMapViewDelegate
//extension ALKShareLocationViewController {
//    
//    override func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        super.mapView(mapView, idleAt: position)
//        pinCoordinate = position.target
//    }
//    
//    override func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
//        super.mapViewDidFinishTileRendering(mapView)
//        
//        if isMapFinishLoading {
//            isLoading = false
//        } else {
//            isLoading = true
//        }
//    }
//}
