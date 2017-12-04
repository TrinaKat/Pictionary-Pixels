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
    var winningScore = 42
    
    @IBOutlet weak var PlayToTextField: UITextField!
    @IBOutlet weak var leastPointsButton: GameButton!
    @IBOutlet weak var averagePointsButton: GameButton!
    @IBOutlet weak var mostPointsButton: GameButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.multipeerService.delegate = self
        
        // Get words with wifi/cellular
        readUrlJSON()
        // a global var
        score = 0
        drawerIndex = 0
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
                dest.winningScore = winningScore
//                dest.startAnswer = answer
            }
        } else if (segue.identifier == "GuessingViewSegue") {
            if let dest = segue.destination as? GuessingViewController {
                dest.multipeerService = multipeerService
                dest.winningScore = winningScore
            }
        }
    }
    
    // MARK: Actions
    // TODO: Send first answerString to both guest/drawer views!
    @IBAction func drawFor5(_ sender: GameButton) {
        print("Least")
        winningScore = 5
        transitionToGame()
    }
    
    @IBAction func drawFor10(_ sender: GameButton) {
        print("10 Pts 4 u")
        winningScore = 10
        transitionToGame()
    }
    
    @IBAction func drawFor20(_ sender: GameButton) {
        print("Most")
        winningScore = 20
        transitionToGame()
    }
    
    func transitionToGame() {
        chooseNewWord()
        let dictionary:NSDictionary = ["answer": answer, "roundPoints": winningScore]
        multipeerService.sendMessage(message: dictionary)
        if UIDevice.current.name == devices![0] {
            self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
        }
    }
}

extension PointsViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            if message["answer"] != nil {
                answer = message["answer"] as! String
                print("RECEIVED ANSWER: \(answer)")
            }
            
            if message["roundPoints"] != nil {
                self.winningScore = message.object(forKey: "roundPoints") as! Int
                // Everyone else becomes a guesser
                if UIDevice.current.name == devices![0] {
                    self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
                }
            }
        }
    }
    
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            // do nothing
        }
    }
}
