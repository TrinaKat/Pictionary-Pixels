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
        self.readLocalJSON()
        self.readMapJSON()
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
    
    // Test JSON parsing
    func readLocalJSON() {
        if let path = Bundle.main.path(forResource: "words", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do{
                    
                    let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    // JSONObjectWithData returns AnyObject so the first thing to do is to downcast to dictionary type
                    print(json)
                    let jsonDictionary =  json as! Dictionary<String,Any>
                    //print all the key/value from the json
                    for (key, value) in jsonDictionary {
                        
                        print("\(key) - \(value) ")
                        
                    }
                    //e.g to get person
                    let personArr = jsonDictionary["person"] as! Array<Dictionary<String,Any>>
                    for (key, value) in personArr.enumerated() {
                        
                        print("\(key) - \(value) ")
                        
                    }
                }catch let error{
                    
                    print(error.localizedDescription)
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func readMapJSON() {
        let url = URL(string: "http://whatsmappening.io:5000/api/event-date/04%20Dec%202017")
//        URLSession.shared.dataTask(with: url!)
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                if let features = json["features"] {
                  print(features)
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
}

extension HomeViewController : MultipeerServiceManagerDelegate {
    
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            if connectedDevices.count == 0 {
                self.connectionsLabel.text = "Players: Just you so far!"
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
