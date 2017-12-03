//
//  HomeViewController.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/13/17.
//  Copyright © 2017 Jason Xu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    // Initialize instance of MultipeerServiceManager
    let multipeerService = MultipeerServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        connectionsLabel.numberOfLines = 0;
        multipeerService.delegate = self as MultipeerServiceManagerDelegate

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    
    // When start is pressed, notify all peers
    // Peers on start screen will handle message in messageReceived()
    @IBAction func startPressed(_ sender: Any) {
        // Pass dictionary on to all players
        let deviceArr = multipeerService.storeDevices()
        let dictionary:NSDictionary = ["startGame": deviceArr]
        multipeerService.sendMessage(message: dictionary)
    }
    
    // Send MultipeerServiceManager with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PointsViewSegue") {
            if let dest = segue.destination as? PointsViewController {
                dest.multipeerService = multipeerService
            }
        }
    }
    
}

extension HomeViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            // Peers who receive "startGame" message should segue to the PointsView
            if let deviceOrdering = message["startGame"] as? [String] {
                devices = deviceOrdering
                print("\n\n\n\n\n\n\n \(devices) \n\n\n\n\n")
                self.performSegue(withIdentifier: "PointsViewSegue", sender: self)
            }
            // Any other messages are unimportant on this view and thus ignored
        }
    }
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            if connectedDevices.count == 0 {
                self.connectionsLabel.text = "Players: Just you so far!"
            } else {
                self.connectionsLabel.text = "Players: \(connectedDevices)"
            }
        }
    }
}
