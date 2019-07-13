//
//  NewRaceViewController.swift
//  Velometer
//
//  Created by William Archimède on 13/07/2019.
//  Copyright © 2019 William Archimede. All rights reserved.
//

import MapKit
import UIKit

class NewRaceViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!

  private var timer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()

    LocationManager.shared.requestWhenInUseAuthorization()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateMapView()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    timer?.invalidate()
    timer = nil
  }
}

// MARK: - Map

extension NewRaceViewController {
  private func updateMapView() {
    guard let coordinate = LocationManager.shared.location?.coordinate else {
      return
    }

    let delta = 0.005
    let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
    mapView.setRegion(region, animated: true)
  }
}
