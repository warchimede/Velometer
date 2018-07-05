//
//  ViewController.swift
//  Velometer
//
//  Created by William Archimède on 04/07/2018.
//  Copyright © 2018 William Archimede. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {

  @IBOutlet weak var startButton: UIBarButtonItem!
  @IBOutlet weak var stopButton: UIBarButtonItem!
  @IBOutlet weak var historyButton: UIBarButtonItem!

  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!

  private var race: Race?
  private var seconds = 0
  private var timer: Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    LocationManager.shared.stopUpdatingLocation()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Actions

  @IBAction func startRace(_ sender: Any) {
    startButton.isEnabled = false
    stopButton.isEnabled = true
    historyButton.isEnabled = false
  }

  @IBAction func stopRace(_ sender: Any) {
    startButton.isEnabled = true
    stopButton.isEnabled = false
    historyButton.isEnabled = true
  }

  // MARK: - Display

  func eachSeconds() {
    seconds += 1
    updateDisplay()
  }

  private func updateDisplay() {
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.minutesPerKilometer)

    distanceLabel.text = formattedDistance
    timeLabel.text = formattedTime
    paceLabel.text = formattedPace
  }
}

extension HomeViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
      }

      locationList.append(newLocation)
    }
  }
}
