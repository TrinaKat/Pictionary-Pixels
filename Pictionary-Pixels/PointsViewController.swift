//
//  PointsViewController.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/30/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

class PointsViewController: UIViewController {
    var multipeerService: MultipeerServiceManager!
    var rounds = 42
    
    @IBOutlet weak var PlayToTextField: UITextField!
    @IBOutlet weak var leastPointsButton: GameButton!
    @IBOutlet weak var averagePointsButton: GameButton!
    @IBOutlet weak var mostPointsButton: GameButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.multipeerService.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send MultipeerServiceManager with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DrawingViewSegue") {
            if let dest = segue.destination as? DrawingViewController {
                dest.multipeerService = multipeerService
                dest.rounds = rounds
            }
        } else if (segue.identifier == "GuessingViewSegue") {
            if let dest = segue.destination as? GuessingViewController {
                dest.multipeerService = multipeerService
                dest.winningScore = rounds
            }
        }
    }
    
    // MARK: Actions
    // TODO: Send first answerString to both guest/drawer views!
    @IBAction func drawFor5(_ sender: GameButton) {
        print("Least")
        let dictionary:NSDictionary = ["roundPoints": 5]
        multipeerService.sendMessage(message: dictionary)
        
        rounds = 5
        
        self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
    }
    
    @IBAction func drawFor10(_ sender: GameButton) {
        print("10 Pts 4 u")
        let dictionary:NSDictionary = ["roundPoints": 10]
        multipeerService.sendMessage(message: dictionary)
        
        rounds = 10
        
        self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
    }
    
    @IBAction func drawFor20(_ sender: GameButton) {
        print("Most")
        let dictionary:NSDictionary = ["roundPoints": 20]
        multipeerService.sendMessage(message: dictionary)
        
        rounds = 20
        
        self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
    }
}

extension PointsViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            if message["roundPoints"] != nil {                
                self.rounds = message.object(forKey: "roundPoints") as! Int
                // Everyone else becomes a guesser
                self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
            }
        }
    }
    
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            // do nothing
        }
    }
}
