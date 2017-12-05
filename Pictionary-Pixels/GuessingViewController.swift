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
    @IBOutlet weak var correctWordlabel: UILabel!
    
    // Constants
    var letterButtonCount: Int = 12
    let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y","z"]
    
    // Variables
    var hiddenLetterLabels = 0
    var guessedLetterIndex = 0
    var deleteChar = " "
    var guess = ""
    var winningScore = 5 // Set this to number of winningScore
    
    func loadData() {
        // Do any additional setup after loading the view.
        guessStatusLabel.isHidden = false
        correctWordlabel.isHidden = true
        updateGuessStatus(toState: CONTINUE_GUESSING)
        inputImageView.image = nil
        
        // Initialize variables
        guessedLetterIndex = 0
        deleteChar = " "
        guess = ""
        winnerLabel.isHidden = true
        currColor = UIColor.black.cgColor
        brushWidth = 8.0
        
        // Enable all the buttons
        deleteButton.isEnabled = true
        deleteButton.alpha = 1.0
        clearButton.isEnabled = true
        clearButton.alpha = 1.0
        
        for i in 0 ... letterButtonCount-1 {
            letterButtons[i].isEnabled = true
            letterButtons[i].alpha = 1.0
        }
        
        // Re-enable all 8 letters
        for i in 0 ... 7 {
            guessedLetterLabels[i].isHidden = false
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
        scoreLabel.text = "Score: " + String(score)
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
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print(winningScore)
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    print("I LALALALALLALALALALALAL")
    winnerLabel.isHidden = true
    correctWordlabel.isHidden = true
    
    // Get words with wifi/cellular
    readUrlJSON()
    loadData()
    
    winnerLabel.numberOfLines = 0;
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    
    // MARK: Actions
  
    // helper just for the status label
    let CONTINUE_GUESSING = 0, CORRECT_GUESS = 1, INCORRECT_GUESS = 2, GAME_OVER = 3
  
    func updateGuessStatus(toState state: Int) {
      switch (state) {
      case CORRECT_GUESS:
        guessStatusLabel.alpha = 1
        guessStatusLabel.text = "Correct!"
        guessStatusLabel.textColor = UIColor.green
        correctWordlabel.text = "Correct Word: \(answer)"
        correctWordlabel.isHidden = false
      case INCORRECT_GUESS:
        guessStatusLabel.alpha = 1
        guessStatusLabel.text = "Incorrect Answer!"
        guessStatusLabel.textColor = UIColor.red
      case GAME_OVER:
        guessStatusLabel.isHidden = true
        correctWordlabel.text = "Correct Word: \(answer)"
        correctWordlabel.isHidden = false
        score = 0
      default:
        guessStatusLabel.alpha = 0.4
        guessStatusLabel.text = "Keep Guessing..."
        guessStatusLabel.textColor = UIColor.black
      }
    }
    
    // Transitions back to points view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GuessingToPointsSegue") {
            if let dest = segue.destination as? PointsViewController {
                dest.multipeerService = multipeerService
            }
        }
        if (segue.identifier == "GuessingToDrawing") {
            if let dest = segue.destination as? DrawingViewController {
                dest.winningScore = winningScore
                dest.multipeerService = multipeerService
            }
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
                guard let deviceOrdering = devices else {
                    print("NO devices stored!")
                    return
                }
                drawerIndex = (1 + drawerIndex) % deviceOrdering.count
                score+=1
                scoreLabel.text = "Score: " + String(score)
                
                // Disable all the buttons
                disableAllButtons()
                
                if score == winningScore {
                    winnerLabel.text = UIDevice.current.name + " WINS! "
                    winnerLabel.isHidden = false
                    updateGuessStatus(toState: GAME_OVER)
                    
                    drawerIndex = 0
                    // Let all peers know that someone won the game
                    // Wait until winner label is displayed before navigating to points view
                    let dictionary:NSDictionary = ["gameOver": "\(UIDevice.current.name) WINS!", "device_name" : "\(UIDevice.current.name)"]
                    self.multipeerService.sendMessage(message: dictionary)

                    // Segue to Points view
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.performSegue(withIdentifier: "GuessingToPointsSegue", sender: self)
                    }
                    
                } else {
                    updateGuessStatus(toState: CORRECT_GUESS)
                    chooseNewWord()
                    
                    let dictionary:NSDictionary = ["newRound": "true", "updateIndex": drawerIndex, "device_name" : "\(UIDevice.current.name)", "answer": answer]
                    multipeerService.sendMessage(message: dictionary)
                    print("\(UIDevice.current.name) \n")
                    print("DRAWER INDEX: \(drawerIndex)")
                    print("CURRENT ARRAY ELEMENT: \(devices![drawerIndex])")
                    if (UIDevice.current.name == devices![drawerIndex]) {
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.performSegue(withIdentifier: "GuessingToDrawing", sender: self)
                        }
                    } else {
                    // Waits until correct guess label is displayed before loading new round
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            // reload the screen
                            self.loadData() // generates new answer and sends to drawer
                        }
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
                self.winnerLabel.text = message["gameOver"] as? String
                self.winnerLabel.isHidden = false
                self.correctWordlabel.text = "Correct Word: \(answer)"
                self.correctWordlabel.isHidden = false
                self.updateGuessStatus(toState: self.GAME_OVER)
                
                // Segue to Points view
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.performSegue(withIdentifier: "GuessingToPointsSegue", sender: self)
                }
            }   // shouldn't call gameOver and updateIndex at same time
            else if message["updateIndex"] != nil {
                print("CURRENT ANSWER WHEN ROUND OVER \(answer) \n \n")
                print("CURRENT ANSWER WHEN ROUND OVER \(answer) \n \n")
                print("CURRENT ANSWER WHEN ROUND OVER \(answer) \n \n")
                print("CURRENT ANSWER WHEN ROUND OVER \(answer) \n \n")
                print("CURRENT ANSWER WHEN ROUND OVER \(answer) \n \n")
                self.correctWordlabel.text = "Correct Word: \(answer)"
                self.correctWordlabel.isHidden = false
                drawerIndex = message["updateIndex"] as! Int
                if (UIDevice.current.name == devices![drawerIndex]) {
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.performSegue(withIdentifier: "GuessingToDrawing", sender: self)
                    }
                } else {
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.loadData()
                    }
                }
            }
            
            if let newAnswer = message["answer"] {
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                answer = newAnswer as! String
            }
            
            if let updatedTime = message["curr_time"] as? Int {
                self.timeLeftLabel.text = ":\(updatedTime)"
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
            
            if let color_key = message["stroke_color"] {
                let color = color_key as! String
                if color == "black" {
                    self.currColor = UIColor.black.cgColor
                } else if color == "red" {
                    self.currColor = UIColor.red.cgColor
                } else if color == "orange" {
                    self.currColor = UIColor.orange.cgColor
                } else if color == "yellow" {
                    self.currColor = UIColor.yellow.cgColor
                } else if color == "green" {
                    self.currColor = UIColor.green.cgColor
                } else if color == "blue" {
                    self.currColor = UIColor.blue.cgColor
                } else if color == "magenta" {
                    self.currColor = UIColor.magenta.cgColor
                } else if color == "brown" {
                    self.currColor = UIColor.brown.cgColor
                } else if color == "Eraser" {
                    self.currColor = UIColor.white.cgColor
                } else {
                    self.currColor = UIColor.black.cgColor
                }
            }
            
            if message["reset"] != nil {
                self.inputImageView.image = nil
            }
        }
    }
}

