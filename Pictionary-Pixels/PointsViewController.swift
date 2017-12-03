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
  @IBOutlet weak var PlayToTextField: UITextField!
  @IBOutlet weak var leastPointsButton: GameButton!
  @IBOutlet weak var averagePointsButton: GameButton!
  @IBOutlet weak var mostPointsButton: GameButton!
    
  let multipeerService = MultipeerServiceManager()
  
  override func viewDidLoad() {
        super.viewDidLoad()
        multipeerService.viewController = self as MultipeerServiceViewManager
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
        multipeerService.start()
    }
    
    @IBAction func drawFor10(_ sender: GameButton) {
        print("10 Pts 4 u")
        multipeerService.start()
    }
    
    @IBAction func drawFor20(_ sender: GameButton) {
        print("Most")
        multipeerService.start()
    }
}

extension PointsViewController : MultipeerServiceViewManager {
    func allToDraw(manager : MultipeerServiceManager) {
        DispatchQueue.main.async() {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "DrawingView") as! DrawingViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    /*func assignViews(manager: MultipeerServiceManager, connectedDevices: [String], firstDrawer: Int) {
        OperationQueue.main.addOperation {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            for i in 0..<connectedDevices.count {
                
            }
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "DrawingViewController") as! DrawingViewController
            self.present(newViewController, animated: true, completion: nil)
        }
    }*/
}
