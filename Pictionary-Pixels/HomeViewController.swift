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
    
    let multipeerService = MultipeerServiceManager()
    
    @IBAction func startPressed(_ sender: Any) {
        multipeerService.stopAdvertisingSelf()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionsLabel.numberOfLines = 0;
        multipeerService.delegate = self as MultipeerServiceManagerDelegate

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController : MultipeerServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            if connectedDevices.count == 0 {
                self.connectionsLabel.text = "Players:"
            } else {
                self.connectionsLabel.text = "Players: \(connectedDevices)"
            }
        }
    }
    
    func startGame(manager: MultipeerServiceManager) {
        DispatchQueue.main.async() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PointsViewController") as! PointsViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
}
