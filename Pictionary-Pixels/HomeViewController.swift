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
    
    var url_words: [Any] = []
    var local_words: [Any] = []
    
    @IBAction func startPressed(_ sender: Any) {
        // Backup if getting words from URL didn't work (takes time)
        self.readLocalJSON()
        var dictionary:NSDictionary = [:]
        
        print("Using following word array:")
        
        if url_words.count <= 0 {
            print(local_words)
            dictionary = ["startGame": "true", "words": local_words]
        } else if local_words.count <= 0 {
            let words = ["this", "is", "hard", "coded", "mochi", "stickers", "candy", "ucla", "bruins"]
            print(words)
            dictionary = ["startGame": "true", "words": words]
        } else {
            print(url_words)
            dictionary = ["startGame": "true", "words": url_words]
        }
        
        multipeerService.sendMessage(message: dictionary)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionsLabel.numberOfLines = 0;
        
        // Get words with wifi/cellular
        self.readUrlJSON()
        
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
//        print("Getting word data locally")
        if let path = Bundle.main.path(forResource: "words", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do{
                    
                    let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    
                    // JSONObjectWithData returns AnyObject so the first thing to do is to downcast to dictionary type
                    //                    print("Entire json file contents:")
                    //                    print(json)
                    
                    // Print all the key/value from the json
                    //                    let jsonDictionary =  json
                    //                    print("Mapping key - values in json:")
                    //                    for (key, value) in jsonDictionary {
                    //                        print("\(key) - \(value) ")
                    //                    }
                    
                    // e.g to get a word
//                    print("Getting words array from json:")
                    let json_words = json["words"]  as! [Any]
                    //                    print(json_words)
                    //                    print(json_words[0])
                    local_words = json_words
                    
                } catch let error {
                    
                    print(error.localizedDescription)
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func readUrlJSON() {
//        print("Getting word data from server via wifi/cellular")
        let url = URL(string: "https://pictionary-pixels.herokuapp.com/")
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
//                print("Getting words array and individual words from url")
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let json_words = json["words"]  as! [Any]
//                print(json_words)
                //                print(json_words[0])
                self.url_words = json_words
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
}

extension HomeViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            // message
            if message["startGame"] != nil {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "PointsViewController") as! PointsViewController
                self.present(newViewController, animated: true, completion: nil)
            }
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
