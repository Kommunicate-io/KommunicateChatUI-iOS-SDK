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

    var configuration: ALKConfiguration!
    
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
            let unspecifiedLocaltionMsg = localizedString(forKey: "UnspecifiedLocation", withDefaultValue: SystemMessage.UIError.unspecifiedLocation, config: configuration)
            return addressText != SystemMessage.UIError.unspecifiedLocation
        }
    }

    init(geocode: Geocode, configuration: ALKConfiguration) {
        self.init(addressText:  geocode.displayName, coor: geocode.location, configuration: configuration)
    }

    init(addressText: String, coor: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: defaultLatitude, longitude: defaultLongitude), configuration: ALKConfiguration) {
        self.address    = addressText
        self.coor       = coor
        self.configuration = configuration
    }
}

