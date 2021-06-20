//
//  LocationModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 18/06/21.
//

import Foundation
import CoreLocation
import MessageKit

struct LocationModel: LocationItem {
    var location: CLLocation
    var size: CGSize = CGSize(width: 200,height: 200)
}
