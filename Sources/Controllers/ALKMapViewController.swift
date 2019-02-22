//
//  ALKMapViewController.swift
//  ApplozicSwift
//
//  Created by Mukesh Thawani on 10/10/17.
//

import UIKit
import MapKit
import Applozic
import Kingfisher

class ALKMapViewController: UIViewController, Localizable {

    var configuration: ALKConfiguration!
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var ShareLocationButton: UIButton!
    
    var locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    var isInitialized = false
    weak var delegate: ALKShareLocationViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.title = localizedString(forKey: "ShareLocationTitle", withDefaultValue: SystemMessage.Map.ShareLocationTitle, fileName: configuration.localizedStringFileName)
        let locationButtonTitle = localizedString(forKey: "SendLocationButton", withDefaultValue: SystemMessage.Map.SendLocationButton, fileName: configuration.localizedStringFileName)
        ShareLocationButton.setTitle(locationButtonTitle, for: UIControl.State.normal)
        ShareLocationButton.setTitle(locationButtonTitle, for: UIControl.State.selected)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }

    func determineCurrentLocation()
    {
//        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }

    @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendLocationAction(_ sender: UIButton) {
        region = mapView.region
        let location = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
        let geoCode = Geocode(coordinates: location)
        self.delegate?.locationDidSelected(geocode: geoCode, image: UIImage())
        self.dismiss(animated: true, completion: nil)
    }

    private func createStaticMap(position: CLLocationCoordinate2D,
                                 success: @escaping (UIImage) -> (),
                                 failure: @escaping (Error?) -> ()) {
        guard let apiKey = ALUserDefaultsHandler.getGoogleMapAPIKey() else {
            failure(nil)
            return
        }
        var urlString: String? = "https://maps.googleapis.com/maps/api/staticmap?" +
            "markers=color:red|size:mid|\(position.latitude),\(position.longitude)" +
            "&zoom=15&size=237x102&maptype=roadmap&scale=2" +
            "&key=\(apiKey)"

        urlString = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        if let urlString = urlString, let url = URL(string: urlString) {

            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image: Image?, error: NSError?, cacheType: CacheType, url: URL?) in


                guard let image = image else {
                    failure(error)
                    return
                }
                success(image)
            }
        }
    }
    
    public func setConfiguration(_ configuration: ALKConfiguration) {
        self.configuration = configuration
    }
}

extension ALKMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isInitialized else { return }
        isInitialized = true
        let userLoction: CLLocation = locations[0]
        let latitude = userLoction.coordinate.latitude
        let longitude = userLoction.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
