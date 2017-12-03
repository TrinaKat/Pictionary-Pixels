//
//  GuessingViewController.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/12/17.
//  Copyright © 2017 Jason Xu. All rights reserved.
//

import UIKit

class GuessingViewController: UIViewController {
    
    // Passed in from PointsView
    var multipeerService: MultipeerServiceManager!
    var rounds: Any!
    
    // Get drawing from drawing view on guessing view
    // Used for replicating drawing on guessing view
    var lastPoint = CGPoint(x: 0, y: 0)
    var currColor: CGColor = UIColor.black.cgColor
    var brushWidth: CGFloat = 8.0
    var viewFrameSize: CGSize?
    
    // DRAWING MAGIC
    // Draws line between 2 points
    func drawLine(from p1: CGPoint, to p2: CGPoint) {
        // Starts empty, want to draw into mainImageView
        // CGContext = 2D drawing environment, with drawing parameters / device info
        // Needed to render drawing correctly for destination (e.g. app window, PDF)
        guard let frameSize = viewFrameSize else {
            print("Guess Size of view frame not initialized yet!")
            return
        }
        
        UIGraphicsBeginImageContext(frameSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("No image context to draw to!")
            return
        }
        
        inputImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
        
        // Add the line data to context from p1 to p2 (p1, p2 very close together)
        context.move(to: p1)
        context.addLine(to: p2)
        
        // Other settings for drawing
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(currColor)
        context.setBlendMode(CGBlendMode.normal)
        
        // MAGIC METHOD to actually form the line
        context.strokePath()
        
        // Wrap up drawing context, render newly drawn line in mainImageView
        // Basically captures what is put on screen into actual graphics and put in a view
        inputImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    // Handle all guessing functionality
    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet var guessedLetterLabels: [GameLetter]!
    @IBOutlet weak var deleteButton: GameButton!
    @IBOutlet weak var clearButton: GameButton!
    @IBOutlet var letterButtons: [GameButton]!
    @IBOutlet weak var guessStatusLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
    // Constants
    var letterButtonCount: Int = 12
    let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y","z"]
    
    // Variables
    var answer: String = "hello"
    var hiddenLetterLabels = 0
    var guessedLetterIndex = 0
    var deleteChar = " "
    var guess = ""
    var score = 0
    var winningScore = 42 // Set this to number of rounds
    
    // Used to determine answer string
    var words: [Any] = []
    var url_words: [Any] = []
    var local_words: [Any] = []
    
    func loadData() {
        // Choose answer string
        // Backup if getting words from URL didn't work (takes time)
        // Next round will try to access url_words again
        // TODO: keep track of used words
        self.readLocalJSON()

        if url_words.count <= 0  && local_words.count > 0{
            words = local_words
        } else if local_words.count <= 0 {
            let hard_coded_words = ["this", "is", "hard", "coded", "mochi", "stickers", "candy", "ucla", "bruins"]
            words = hard_coded_words
        } else {
            words = url_words
        }
        print("Using following word array in PointsView:")
        print(words)
        
        let answer_num = arc4random_uniform(UInt32(words.count))
        answer = words[Int(answer_num)] as! String
        print("The chosen answer is:")
        print(answer)
        
        // Send answer to all peers
        let dictionary:NSDictionary = ["answer": answer, "newRound": "true"]
        multipeerService.sendMessage(message: dictionary)

        // Do any additional setup after loading the view.
        updateGuessStatus(toState: 0)
        
        // Initialize variables
        guessedLetterIndex = 0
        deleteChar = " "
        guess = ""
        winnerLabel.isHidden = true
        
        // Enable all the buttons
        deleteButton.isEnabled = true
        deleteButton.alpha = 1.0
        clearButton.isEnabled = true
        clearButton.alpha = 1.0
        
        for i in 0 ... letterButtonCount-1 {
            letterButtons[i].isEnabled = true
            letterButtons[i].alpha = 1.0
        }
        
        // Initializing guessed letter labels
        if (answer.count < 8) {
            hiddenLetterLabels = 8 - answer.count
            
            for i in 1 ... hiddenLetterLabels {
                guessedLetterLabels[8-i].isHidden = true
            }
        }
        
        for i in 0 ... answer.count-1 {
            guessedLetterLabels[i].text = " "
        }
        
        // Generating keyboard
        var counter: Int = 0
        var slots = [Int]()
        
        // For every letter in the answer assign it a random position on the board
        while counter < answer.count {
            let num = arc4random_uniform(UInt32(letterButtonCount))
            
            // 1:1, slot number stored in slots[], actual char stored in lettersAlreadyOnBoard[]
            if !slots.contains(Int(num)) {
                slots.append(Int(num))
                counter+=1
            }
        }
        
        counter = 0
        
        // For every slot, assign the letterButtons to the char determined in above loop
        for i in 0 ... answer.count-1 {
        letterButtons[slots[i]].setTitle(String(answer[answer.index(answer.startIndex, offsetBy: i)]), for: UIControlState.normal)
        }
        
        // Fill in remaining empty slots with random letters
        // We allow duplicate/triplicate/multiples of letters, because it's random
        while counter < letterButtonCount {
            if !slots.contains(counter) {
                let chosenLetter = alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(26)))]
                letterButtons[counter].setTitle(chosenLetter, for: UIControlState.normal)
                counter+=1
            } else {
                counter+=1
            }
        }
        
        // Clear any past drawings
        inputImageView.image = nil
    }
    
    func disableAllButtons() {
        for i in 0 ... letterButtonCount-1 {
            letterButtons[i].isEnabled = false
            letterButtons[i].alpha = 0.3

            deleteButton.isEnabled = false
            deleteButton.alpha = 0.3

            clearButton.isEnabled = false
            clearButton.alpha = 0.3
        }
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    self.multipeerService.delegate = self
    viewFrameSize = inputImageView.frame.size
    winningScore = rounds as! Int
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print(winningScore)
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    score = 0
    winnerLabel.isHidden = true
    
    // Get words with wifi/cellular
    self.readUrlJSON()
    self.loadData()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    
    // MARK: Actions
  
    // helper just for the status label
    let CONTINUE_GUESSING = 0, CORRECT_GUESS = 1, INCORRECT_GUESS = 2
  
    func updateGuessStatus(toState state: Int) {
      switch (state) {
      case CORRECT_GUESS:
        guessStatusLabel.alpha = 1
        guessStatusLabel.text = "Correct!"
        guessStatusLabel.textColor = UIColor.green
      case INCORRECT_GUESS:
        guessStatusLabel.alpha = 1
        guessStatusLabel.text = "Incorrect Answer!"
        guessStatusLabel.textColor = UIColor.red
      default:
        guessStatusLabel.alpha = 0.4
        guessStatusLabel.text = "Keep Guessing..."
        guessStatusLabel.textColor = UIColor.black
      }
    }

    // Get letter on pushed button
    // Assign it to the first available guessedLetterLabel
    // Make button inactive both programmatically + visually
    @IBAction func enterLetter(_ sender: UIButton) {
        print("User clicked \(String(describing: sender.titleLabel!.text))")
        // print("User clicked \(sender.titleLabel?.text ?? "FAILURE")")
        
        if guessedLetterIndex < answer.count {
            // Assign letter to label
            guessedLetterLabels[guessedLetterIndex].text = sender.titleLabel!.text
            guessedLetterIndex+=1
            
            // Deactivate button
            sender.isEnabled = false
            sender.alpha = 0.3
        }
        
        // Automatically send guess
        // If correct, display "Correct Guess by <device_name>!" on all screens
        // Give correct guesser 1 point
        // Transition to next round
        // If incorrect, display "Incorrect Guess!" on the incorrect guesser's screen
        // Display of "Incorrect Guess!" should GO AWAY after player hits delete again
        if guessedLetterIndex == answer.count {
            for i in 0 ... answer.count-1 {
                guess += guessedLetterLabels[i].text!
            }
            // Check guess string against answer string
            if guess == answer {
                score+=1
                scoreLabel.text = "Score: " + String(score)
                
                // Disable all the buttons
                disableAllButtons()
                
                if score == winningScore {
                    winnerLabel.isHidden = false
                    
                    // Let all peers know that someone won the game
                    // Wait until winner label is displayed before navigating to points view
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        let dictionary:NSDictionary = ["gameOver": "true"]
                        self.multipeerService.sendMessage(message: dictionary)
                    }
                } else {
                    updateGuessStatus(toState: CORRECT_GUESS)
                    
                    // Waits until correct guess label is displayed before loading new round
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        // reload the screen
                        self.loadData() // generates new answer and sends to drawer
                    }
                }
            } else {
                updateGuessStatus(toState: INCORRECT_GUESS)
                guess = ""
            }
        }
    }

    // Delete the last assigned guessedLetterLabel
    // Make corresponding letterButton available again
    // If "Incorrect Guess" text label is shown, hide it
    @IBAction func deleteLetter(_ sender: UIButton) {
        updateGuessStatus(toState: CONTINUE_GUESSING)

        if guessedLetterIndex > 0 {
            guessedLetterIndex-=1
            
            // Figure out which letter to remove from guessed chars and add to buttons
            let deleteChar = guessedLetterLabels[guessedLetterIndex].text
            guessedLetterLabels[guessedLetterIndex].text = " "
            
            // Reactivate button
            for i in 0 ... letterButtonCount-1 {
                if !letterButtons[i].isEnabled && letterButtons[i].titleLabel!.text == deleteChar {
                    letterButtons[i].isEnabled = true
                    letterButtons[i].alpha = 1.0
                    break
                }
            }
        }
    }

    // Delete all assigned guessedLetterLabels
    // Make all corresponding letterButtons available again
    @IBAction func clearAll(_ sender: Any) {
        updateGuessStatus(toState: CONTINUE_GUESSING)
        
        for i in 0 ... 7 {
            guessedLetterLabels[i].text = " "
        }
        
        for i in 0 ... letterButtonCount-1 {
            letterButtons[i].isEnabled = true
            letterButtons[i].alpha = 1.0
        }
        
        guessedLetterIndex = 0
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

extension GuessingViewController: MultipeerServiceManagerDelegate{
    func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            // do nothing
        }
    }
    
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        OperationQueue.main.addOperation {
            // message
            if message["gameOver"] != nil {
                // Transition to PointsViewController
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "PointsViewController")
                self.present(newViewController, animated: true, completion: nil)
            }
            
            if let point = message["new_point"] {
                self.lastPoint = ((point as? NSValue)?.cgPointValue)!
            }
            
            if let point = message["current_point"] {
                self.drawLine(from: self.lastPoint, to: ((point as? NSValue)?.cgPointValue)!)
                self.lastPoint = ((point as? NSValue)?.cgPointValue)!
            }
            
            if let point = message["last_point"] {
                self.drawLine(from: self.lastPoint, to: ((point as? NSValue)?.cgPointValue)!)
            }
            
            if let width = message["brush_width"] {
                self.brushWidth = width as! CGFloat
            }
            
            if let color = message["stroke_color"] {
                self.currColor = color as! CGColor
            }
            
            if message["reset"] != nil {
                self.inputImageView.image = nil
            }
        }
    }
}

