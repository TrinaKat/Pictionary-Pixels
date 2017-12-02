//
//  GuessingViewController.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/12/17.
//  Copyright © 2017 Jason Xu. All rights reserved.
//

import UIKit

class GuessingViewController: UIViewController {
    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet var guessedLetterLabels: [GameLetter]!
    @IBOutlet weak var deleteButton: GameButton!
    @IBOutlet weak var clearButton: GameButton!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet var letterButtons: [GameButton]!
    @IBOutlet weak var guessStatusLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var hiddenLetterLabels = 0
    let answer = "hello"
    var letterButtonCount: Int = 12
    let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y","z"]
    
    var guessedLetterIndex = 0
    var deleteChar = " "
    var guess = ""
    var score = 0
    var winningScore = 5 // TODO: set this with button press
    
    func loadData() {
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
        
        // generating keyboard
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
    score = 0
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
                
                disableAllButtons()
                
                if score == winningScore {
                    winnerLabel.isHidden = false
                    
                    // Waits until winnderLabel is displayed before navigating to points view
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        // Go to points view
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PointsViewController")
                        self.present(newViewController, animated: true, completion: nil)
                    }
                } else {
                    updateGuessStatus(toState: CORRECT_GUESS)
                    
                    // Waits until correctGuessLabel is displayed before loading new round
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        // reload the screen
                        self.loadData()
                    }
                }
                // TODO: notify everyone by displaying "Correct Guess by <device_name>!" on all screens
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

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
