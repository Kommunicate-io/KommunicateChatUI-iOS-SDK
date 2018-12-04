//
//  LocationPreviewViewModel.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import CoreLocation

struct ALKLocationPreviewViewModel: Localizable {

    fileprivate var localizedStringFileName: String!
    
    private var address: String
    private var coor: CLLocationCoordinate2D

    var addressText: String {
        get {
            return address
        }
    }

    var coordinate: CLLocationCoordinate2D {
        get {
            return coor
        }
    }

    var isReady: Bool {
        get {
            let unspecifiedLocationMsg = localizedString(forKey: "UnspecifiedLocation", withDefaultValue: SystemMessage.UIError.unspecifiedLocation, fileName: localizedStringFileName)
            return addressText != unspecifiedLocationMsg
        }
    }

    init(geocode: Geocode, localizedStringFileName: String) {
        self.init(addressText:  geocode.displayName, coor: geocode.location, localizedStringFileName: localizedStringFileName)
    }

    init(addressText: String, coor: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), localizedStringFileName: String) {
        self.address    = addressText
        self.coor       = coor
        self.localizedStringFileName = localizedStringFileName
    }
}

