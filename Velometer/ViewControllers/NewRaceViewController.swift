//
//  NewRaceViewController.swift
//  Velometer
//
//  Created by William Archimède on 13/07/2019.
//  Copyright © 2019 William Archimede. All rights reserved.
//

import CoreLocation
import UIKit

class NewRaceViewController: UIViewController {

  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!

  private var race: Race?
  private var seconds = 0
  private var timer: Timer?
  private var distance: Measurement<UnitLength> = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    startRace()
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */

  private func startRace() {
    timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.seconds += 1
      self?.updateDisplay()
    }

    startUpdatingLocation()
  }

  private func updateDisplay() {
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedSpeed = FormatDisplay.speedOrPace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.kilometersPerHour)
    let formattedPace = FormatDisplay.speedOrPace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerKilometer)

    distanceLabel.text = formattedDistance
    timeLabel.text = formattedTime
    speedLabel.text = formattedSpeed
    paceLabel.text = formattedPace
  }
}

// MARK: - Location

extension NewRaceViewController: CLLocationManagerDelegate {
  private func startUpdatingLocation() {
    LocationManager.shared.delegate = self
    LocationManager.shared.activityType = .fitness
    LocationManager.shared.distanceFilter = 10
    LocationManager.shared.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locations.forEach { newLocation in
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { return }

      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
      }

      locationList.append(newLocation)
    }
  }
}
