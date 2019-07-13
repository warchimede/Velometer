//
//  RaceRecapViewController.swift
//  Velometer
//
//  Created by William Archimède on 13/07/2019.
//  Copyright © 2019 William Archimede. All rights reserved.
//

import MapKit
import UIKit

class RaceRecapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!

  var race: RaceProxy?

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadMap()
    updateDisplay()
  }

  // MARK: - Actions

  @IBAction func save(_ sender: Any) {
    if let race = race {
      let newRace = Race(context: CoreDataStack.context)
      newRace.distance = race.distance.value
      newRace.duration = Int16(race.duration)
      newRace.date = race.date

      race.locations.forEach { location in
        let locationObject = Location(context: CoreDataStack.context)
        locationObject.timestamp = location.timestamp
        locationObject.latitude = location.coordinate.latitude
        locationObject.longitude = location.coordinate.longitude
        newRace.addToLocations(locationObject)
      }

      CoreDataStack.saveContext()
    }

    view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func dismiss(_ sender: Any) {
    view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  // MARK: - Display

  private func updateDisplay() {
    guard let race = race else { return }

    title = FormatDisplay.date(race.date, style: .long)

    let formattedDistance = FormatDisplay.distance(race.distance)
    let formattedTime = FormatDisplay.time(race.duration)
    let formattedSpeed = FormatDisplay.speedOrPace(distance: race.distance, seconds: race.duration, outputUnit: UnitSpeed.kilometersPerHour)
    let formattedPace = FormatDisplay.speedOrPace(distance: race.distance, seconds: race.duration, outputUnit: UnitSpeed.minutesPerKilometer)

    distanceLabel.text = formattedDistance
    timeLabel.text = formattedTime
    speedLabel.text = formattedSpeed
    paceLabel.text = formattedPace
  }
}

// Mark: - Map

extension RaceRecapViewController: MKMapViewDelegate {
  private func mapRegion() -> MKCoordinateRegion {
    guard let locations = race?.locations
      else {
        return MKCoordinateRegion()
    }

    let latitudes = locations.map { return $0.coordinate.latitude }
    let longitudes = locations.map { return $0.coordinate.longitude }

    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!

    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLong - minLong) * 1.3)

    return MKCoordinateRegion(center: center, span: span)
  }

  private func polyLine() -> MKPolyline {
    guard let locations = race?.locations
      else {
        return MKPolyline()
    }

    let coords: [CLLocationCoordinate2D] = locations.map {
      return CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
    }

    return MKPolyline(coordinates: coords, count: coords.count)
  }

  private func loadMap() {
    mapView.setRegion(mapRegion(), animated: true)
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
