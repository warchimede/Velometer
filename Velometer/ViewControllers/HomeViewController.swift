//
//  ViewController.swift
//  Velometer
//
//  Created by William Archimède on 04/07/2018.
//  Copyright © 2018 William Archimede. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet weak var startButton: UIBarButtonItem!
  @IBOutlet weak var stopButton: UIBarButtonItem!
  @IBOutlet weak var historyButton: UIBarButtonItem!

  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!

  private var race: Race?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

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
}

