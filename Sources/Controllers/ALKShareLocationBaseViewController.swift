//
//  ALKShareLocationBaseViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
//import GoogleMaps
import CoreLocation


let defaultMapZoomLevel: Float  = 16
let defaultLatitude             = 13.765221
let defaultLongitude            = 100.538338
let minimumMapZoomLevel: Float  = 3
let maxmimumMapZoomLevel: Float = 34


class ALKShareLocationBaseViewController: ALKBaseViewController {

//    @IBOutlet internal weak var mapView: GMSMapView!
}
//    var isMapFinishLoading: Bool = false
//    fileprivate var hasMapMovedToUserLocation   = false
//    fileprivate var registeredMyLocation: Bool  = false
//    fileprivate var initialUserCurrentLocation: CLLocation?
//    fileprivate var lastZoomLevel: Float        = defaultMapZoomLevel
//    fileprivate lazy var defaultLocation        = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude)
//    
//    lazy var locationManager: CLLocationManager = CLLocationManager.initializeLocationManager(delegate: self)
//    
//    //private var currentLocation: CLLocation?
//    var isObserveMyLocation: Bool {
//        return true
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupMap()
//        navigateToEntryPoint()
//        askForLocationPermission()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        observeMyLocation()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        resignObserveMyLocation()
//    }
//    
//    private func setupMap() {
//        mapView.setMinZoom(minimumMapZoomLevel, maxZoom: maxmimumMapZoomLevel)
//        mapView.settings.zoomGestures               = false
//        mapView.settings.consumesGesturesInView     = false
//        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
//        mapView.delegate                            = self
//        mapView.isMyLocationEnabled                 = true
//        
//        centerMapWhilePinch()
//    }
//    
//    func navigateToEntryPoint() {
//         animateToDefaultLocation()
//    }
//    
//    func isInitialLocationReceived() -> Bool {
//        if initialUserCurrentLocation == nil {
//            return false
//        }
//        return true
//    }
//    
//    func getInitialCurrentLocation() -> CLLocation? {
//        return initialUserCurrentLocation
//    }
//    
//    private func centerMapWhilePinch() {
//        let pinchSelector           = #selector(pinchHandler(gesture:))
//        let pinchGestureRecognizer  = UIPinchGestureRecognizer(target: self, action: pinchSelector)
//        mapView.addGestureRecognizer(pinchGestureRecognizer)
//    }
//    
//    private func animateToDefaultLocation() {
//        animateAndDefaultZoom(toLocation: defaultLocation)
//    }
//    
//    func animateAndDefaultZoom(toLocation: CLLocationCoordinate2D) {
//        mapView.animate(toLocation: toLocation)
//        mapView.animate(toZoom: defaultMapZoomLevel)
//    }
//    
//    func moveToLocation(toLocation:CLLocationCoordinate2D) {
//        mapView.camera = GMSCameraPosition.camera(withTarget: toLocation, zoom: defaultMapZoomLevel)
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "myLocation" {
//            guard let obj = object else {
//                return
//            }
//            
//            if let map = obj as? GMSMapView {
//                if !hasMapMovedToUserLocation {
//                    initialUserCurrentLocation = map.myLocation
//                }
//            }
//        }
//    }
//
//    private func observeMyLocation() {
//        if !isObserveMyLocation { return }
//        
//        if (!registeredMyLocation) {
//            mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
//            registeredMyLocation = !registeredMyLocation
//        }
//    }
//    
//    private func resignObserveMyLocation() {
//        if !isObserveMyLocation { return }
//        
//        if (registeredMyLocation) {
//            mapView?.removeObserver(self, forKeyPath: "myLocation")
//            registeredMyLocation = !registeredMyLocation
//        }
//    }
//    
//    // MARK: Pinch
//    func pinchHandler(gesture: UIGestureRecognizer) {
//        
//        guard let pinch = gesture as? UIPinchGestureRecognizer else {
//            return
//        }
//        
//        switch pinch.state {
//        case UIGestureRecognizerState.began:
//            lastZoomLevel = mapView.camera.zoom
//        case UIGestureRecognizerState.changed:
//            let scale: Float = Float(pinch.scale)
//            let newScale: Float = scale + ((1 - scale) * 0.8)
//            let zoom = lastZoomLevel * newScale
//            let isOverMax = (zoom > maxmimumMapZoomLevel)
//            let isUnderMin = (zoom < minimumMapZoomLevel)
//            let newZoom = isOverMax ? maxmimumMapZoomLevel : (isUnderMin ? minimumMapZoomLevel : zoom)
//            mapView.moveCamera(GMSCameraUpdate.zoom(to: newZoom))
//        case UIGestureRecognizerState.ended:
//            let scale: Float = Float(pinch.scale)
//            let velocity: Float = Float(pinch.velocity)
//            let newScale: Float = scale + ((1 - scale) * 0.8)
//            let newScale2: Float = newScale + (velocity / 100.0)
//            let zoom = lastZoomLevel * newScale
//            let isOverMax = (zoom > maxmimumMapZoomLevel)
//            let isUnderMin = (zoom < minimumMapZoomLevel)
//            let newZoom = isOverMax ? maxmimumMapZoomLevel : (isUnderMin ? minimumMapZoomLevel : zoom)
//            let zoom2 = lastZoomLevel * newScale2
//            let isOverMax2 = (zoom2 > maxmimumMapZoomLevel)
//            let isUnderMin2 = (zoom2 < minimumMapZoomLevel)
//            let newZoom2 = isOverMax2 ? maxmimumMapZoomLevel : (isUnderMin2 ? minimumMapZoomLevel : zoom2)
//            if fabs(velocity) > 0.2 {
//                mapView.animate(toZoom: newZoom2)
//            } else {
//                mapView.moveCamera(GMSCameraUpdate.zoom(to: newZoom))
//            }
//        default:
//            ()
//        }
//    }
//    
//    func askForLocationPermission() {
//        locationManager.requestMyLocation()
//        locationManager.stopMyLocationRequest()
//    }
//    
//    @IBAction func locateMe() {
//        guard let location = mapView.myLocation else {
//            CLLocationManager.showLocationPermissionAlert(vc: self)
//            return
//        }
//        animateAndDefaultZoom(toLocation: location.coordinate)
//    }
//}
//
//
//// MARK: - GMSViewDelegate
//extension ALKShareLocationBaseViewController: GMSMapViewDelegate {
//    
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//    }
//    
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//    }
//    
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        guard let markerLocationView = Bundle.main.loadNibNamed("MarkerInfoWindowView", owner: self, options: nil)?[0] as? MarkerInfoWindowView else {
//            return nil
//        }
//        
//        markerLocationView.updateContent(marker: marker)
//        return markerLocationView
//    }
//    
//    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
//        if isMapFinishLoading == false {
//            isMapFinishLoading = true
//            
//            if !hasMapMovedToUserLocation,let loc = initialUserCurrentLocation{
//                hasMapMovedToUserLocation = true
//                moveToLocation(toLocation:  loc.coordinate)
//            }
//        }
//    }
//}
//
//
//// MARK: - CLLocationManagerDelegate
//extension ALKShareLocationBaseViewController: CLLocationManagerDelegate {
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        if let mostRecentLocation = locations.last {
//            animateAndDefaultZoom(toLocation: mostRecentLocation.coordinate)
//        }
//        locationManager.stopUpdatingLocation()
//
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
////        switch status {
////        case .restricted:
////        case .denied:
////        case .notDetermined:
////        case .authorizedAlways: fallthrough
////        case .authorizedWhenInUse:
////        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//    }
//}
