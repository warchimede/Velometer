//
//  ViewController.swift
//  Velometer
//
//  Created by William Archimède on 04/07/2018.
//  Copyright © 2018 William Archimede. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {

  @IBOutlet weak var startButton: UIBarButtonItem!
  @IBOutlet weak var stopButton: UIBarButtonItem!
  @IBOutlet weak var historyButton: UIBarButtonItem!

  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!

  @IBOutlet weak var mapView: MKMapView!

  private var race: Race?
  private var seconds = 0
  private var timer: Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    LocationManager.shared.stopUpdatingLocation()
  }

  // MARK: - Actions

  @IBAction func startRace(_ sender: Any) {
    startButton.isEnabled = false
    stopButton.isEnabled = true
    historyButton.isEnabled = false

    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSeconds()
    }
    startLocationUpdates()
  }

  @IBAction func stopRace(_ sender: Any) {
    startButton.isEnabled = true
    stopButton.isEnabled = false
    historyButton.isEnabled = true

    LocationManager.shared.stopUpdatingLocation()

    let alert = UIAlertController(title: "The race is over", message: "Should it be saved ?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.saveRace()
      self.loadMap()
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    present(alert, animated: true)
  }

  // MARK: - Display

  func eachSeconds() {
    seconds += 1
    updateDisplay()
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

    if let coordinate = LocationManager.shared.location?.coordinate {
      let delta = 0.005
      let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
      mapView.setRegion(region, animated: true)
    }
  }

  // MARK: - Saving

  private func saveRace() {
    let newRace = Race(context: CoreDataStack.context)
    newRace.distance = distance.value
    newRace.duration = Int16(seconds)
    newRace.date = Date()

    locationList.forEach { location in
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newRace.addToLocations(locationObject)
    }

    CoreDataStack.saveContext()

    race = newRace
  }
}

// MARK: - Mapping

extension HomeViewController: MKMapViewDelegate {
  private func mapRegion() -> MKCoordinateRegion? {
    guard let locations = race?.locations, locations.count > 0
      else {
        return nil
    }

    let latitudes = locations.map { return ($0 as! Location).latitude }
    let longitudes = locations.map { return ($0 as! Location).longitude }

    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!

    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)

    return MKCoordinateRegion(center: center, span: span)
  }

  private func polyLine() -> MKPolyline {
    guard let locations = race?.locations else {
      return MKPolyline()
    }

    let coords: [CLLocationCoordinate2D] = locations.map {
      let location = $0 as! Location
      return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    return MKPolyline(coordinates: coords, count: coords.count)
  }

  private func loadMap() {
    guard let locations = race?.locations,
      locations.count > 0,
      let region = mapRegion()
      else {
        return
    }

    mapView.setRegion(region, animated: true)
    mapView.addOverlay(polyLine())
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }

    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}

// MARK: - Location

extension HomeViewController: CLLocationManagerDelegate {
  private func startLocationUpdates() {
    LocationManager.shared.delegate = self
    LocationManager.shared.activityType = .fitness
    LocationManager.shared.distanceFilter = 10
    LocationManager.shared.startUpdatingLocation()
  }

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
