//
//  FormatDisplay.swift
//  Velometer
//
//  Created by William Archimède on 05/07/2018.
//  Copyright © 2018 William Archimede. All rights reserved.
//

import Foundation

struct FormatDisplay {
  static func distance(_ distance: Measurement<UnitLength>) -> String {
    return MeasurementFormatter().string(from: distance)
  }

  static func time(_ seconds: Int) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: TimeInterval(seconds)) ?? ""
  }

  static func speedOrPace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
    let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
    let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
    let formatter = MeasurementFormatter()
    formatter.unitOptions = [.providedUnit]
    return formatter.string(from: speed.converted(to: outputUnit))
  }

  static func date(_ timestamp: Date?) -> String {
    guard let timestamp = timestamp as Date? else { return "" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: timestamp)
  }
}
