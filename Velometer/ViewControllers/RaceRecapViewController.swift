//
//  RaceRecapViewController.swift
//  Velometer
//
//  Created by William Archimède on 13/07/2019.
//  Copyright © 2019 William Archimede. All rights reserved.
//

import UIKit

class RaceRecapViewController: UIViewController {

  var race: Race?

  @IBAction func save(_ sender: Any) {
    if race != nil {
      CoreDataStack.saveContext()
    }

    view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func dismiss(_ sender: Any) {
    view.window?.rootViewController?.dismiss(animated: true, completion: nil)
  }
}
