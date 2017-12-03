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
    
    // Used to determine answer string
    var words: [Any] = []
    var url_words: [Any] = []
    var local_words: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.multipeerService.delegate = self
        
        // Get words with wifi/cellular
        self.readUrlJSON()

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
//                dest.startAnswer = answer
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
        
        self.chooseNewWord()
        
        if UIDevice.current.name == devices![0] {
            self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
        }
    }
    
    @IBAction func drawFor10(_ sender: GameButton) {
        print("10 Pts 4 u")
        let dictionary:NSDictionary = ["roundPoints": 10]
        multipeerService.sendMessage(message: dictionary)
        
        rounds = 10
        
        self.chooseNewWord()
        
        if UIDevice.current.name == devices![0] {
            self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
        }
    }
    
    @IBAction func drawFor20(_ sender: GameButton) {
        print("Most")
        let dictionary:NSDictionary = ["roundPoints": 20]
        multipeerService.sendMessage(message: dictionary)
        
        rounds = 20
        
        self.chooseNewWord()
        
        if UIDevice.current.name == devices![0] {
            self.performSegue(withIdentifier: "DrawingViewSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "GuessingViewSegue", sender: self)
        }
    }
    
    func chooseNewWord() {
        self.readLocalJSON()
        
        if url_words.count <= 0  && local_words.count > 0 {
            words = local_words
        } else if local_words.count <= 0 {
            let hard_coded_words = ["this", "is", "hard", "coded", "mochi", "stickers", "candy", "ucla", "bruins"]
            words = hard_coded_words
        } else {
            words = url_words
        }
        print("Using following word array in PointsView:")
        print(words)
        
        // Answer is global for device, so already initialized to non-"hello" value
        let answer_num = arc4random_uniform(UInt32(words.count))
        answer = words[Int(answer_num)] as! String
        print("The chosen answer is:")
        print(answer)
    }
    
    // Get JSON data from a local JSON file
    // Backup if web server is down
    func readLocalJSON() {
        if let path = Bundle.main.path(forResource: "words", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do{
                    
                    let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    
                    // JSONObjectWithData returns AnyObject so the first thing to do is to downcast to dictionary type
                    // Print all the key/values from the JSON
                    // let jsonDictionary =  json
                    // for (key, value) in jsonDictionary {
                    //      print("\(key) - \(value) ")
                    // }
                    
                    let json_words = json["words"]  as! [Any]
                    // print(json_words)
                    // print(json_words[0])
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
    
    // Read a JSON from a URL via wifi/cellular data
    func readUrlJSON() {
        let url = URL(string: "https://pictionary-pixels.herokuapp.com/")
        URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let json_words = json["words"]  as! [Any]
                // print(json_words)
                // print(json_words[0])
                self.url_words = json_words
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    
}

extension PointsViewController : MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            if message["roundPoints"] != nil {                
                self.rounds = message.object(forKey: "roundPoints") as! Int
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
