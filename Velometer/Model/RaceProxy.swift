//
//  RaceProxy.swift
//  Velometer
//
//  Created by William Archimède on 13/07/2019.
//  Copyright © 2019 William Archimede. All rights reserved.
//

import CoreLocation
import Foundation

struct RaceProxy {
  let distance: Double
  let duration: Int
  let date: Date
  let locations: [CLLocation]
}
