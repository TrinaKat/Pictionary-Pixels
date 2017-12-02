//
//  PointsViewController.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/30/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit
//import "DrawingViewController.h"

class PointsViewController: UIViewController {
//    var multipeerService: MultipeerServiceManager!
    let multipeerService = MultipeerServiceManager()
    
  @IBOutlet weak var PlayToTextField: UITextField!
  @IBOutlet weak var leastPointsButton: GameButton!
  @IBOutlet weak var averagePointsButton: GameButton!
  @IBOutlet weak var mostPointsButton: GameButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        self.multipeerService.delegate = self as? MultipeerServiceManagerDelegate

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
    
    // MARK: Actions
    @IBAction func drawFor5(_ sender: GameButton) {
        print("Least")
        
        let dictionary:NSDictionary = ["roundPoints": 5] //, "words": self.words]
        multipeerService.sendMessage(message: dictionary)
    }
    
    @IBAction func drawFor10(_ sender: GameButton) {
        print("10 Pts 4 u")
        let dictionary:NSDictionary = ["roundPoints": 10]
        multipeerService.sendMessage(message: dictionary)
    }
    
    @IBAction func drawFor20(_ sender: GameButton) {
        print("Most")
        let dictionary:NSDictionary = ["roundPoints": 20]
        multipeerService.sendMessage(message: dictionary)
    }
}

extension PointsViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            // message
            if message["roundPoints"] != nil {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "DrawingView") as! DrawingViewController
                self.present(newViewController, animated: true, completion: nil)
            }
            
//            let points = message["roundPoints"]
//            // What if nil
//            if points as! Int == 5 {
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let newViewController = storyBoard.instantiateViewController(withIdentifier: "DrawingView") as! DrawingViewController
//                self.present(newViewController, animated: true, completion: nil)
//            } else if points as! Int == 10 {
//                print("10 away from awesome")
////                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////                let newViewController = storyBoard.instantiateViewController(withIdentifier: "GuessingView") as! GuessingViewController
////                self.present(newViewController, animated: true, completion: nil)
//            } else if points as! Int == 20 {
//                print("That 20 good life")
////                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////                let newViewController = storyBoard.instantiateViewController(withIdentifier: "MessageView") as! MessageViewController
////                self.present(newViewController, animated: true, completion: nil)
//            }
        }
    }
    
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            // do nothing
        }
    }
}
