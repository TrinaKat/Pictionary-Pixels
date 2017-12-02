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
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet var guessedLetterLabels: [GameLetter]!
    @IBOutlet var letterButtons: [GameButton]!
    @IBOutlet weak var incorrectGuessLabel: UILabel!
    @IBOutlet weak var correctGuessLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    var hiddenLetterLabels = 0

    let answer = "hello"
    
  override func viewDidLoad() {
      super.viewDidLoad()

//    let answer = "hello"
    let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y","z"]
    
    // Do any additional setup after loading the view.
    
    // initializing guessed letter labels
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
        let letter = String(answer[answer.index(answer.startIndex, offsetBy: counter)])
        let num = arc4random_uniform(14)
    
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
    while counter < 14 {
        if !slots.contains(counter) {
            let chosenLetter = alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(26)))]
            letterButtons[counter].setTitle(chosenLetter, for: UIControlState.normal)
            counter+=1
        } else {
            counter+=1
        }
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
    // MARK: Actions
    var guessedLetterIndex = 0
    var deleteChar = " "
    var guess = ""
    var score = 0
    
    // Get letter on pushed button
    // Assign it to the first available guessedLetterLabel
    // Make button inactive both programmatically + visually
    @IBAction func enterLetter(_ sender: UIButton) {
        print("User clicked \(String(describing: sender.titleLabel!.text))")
        // print("User clicked \(sender.titleLabel?.text ?? "FAILURE")")
        
        incorrectGuessLabel.isHidden = true
        
        if guessedLetterIndex < answer.count {
            // Assign letter to label
            guessedLetterLabels[guessedLetterIndex].text = sender.titleLabel!.text
            guessedLetterIndex+=1
            
            // Deactivate button
            sender.isEnabled = false
            sender.alpha = 0.3
        }
    }

    // Delete the last assigned guessedLetterLabel
    // Make corresponding letterButton available again
    // If "Incorrect Guess" text label is shown, hide it
    @IBAction func deleteLetter(_ sender: UIButton) {
        incorrectGuessLabel.isHidden = true
        
        if guessedLetterIndex > 0 {
            guessedLetterIndex-=1
            
            // Figure out which letter to remove from guessed chars and add to buttons
            let deleteChar = guessedLetterLabels[guessedLetterIndex].text
            guessedLetterLabels[guessedLetterIndex].text = " "
            
            // Reactivate button
            for i in 0 ... 13 {
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
    @IBAction func clear(_ sender: Any) {
        incorrectGuessLabel.isHidden = true

        for i in 0 ... 7 {
            guessedLetterLabels[i].text = " "
        }
        
        for i in 0 ... 13 {
            letterButtons[i].isEnabled = true
            letterButtons[i].alpha = 1.0
        }
        
        guessedLetterIndex = 0
    }

    // Send guess and check it with the answer string
    // If correct, display "Correct Guess by <device_name>!" on all screens
    // Give correct guesser 1 point
    // Transition to next round
    // If incorrect, display "Incorrect Guess!" on the incorrect guesser's screen
    // Display of "Incorrect Guess!" should GO AWAY after player hits delete again
    @IBAction func sendGuess(_ sender: Any) {
        // TODO: It would be easy to automatically check guess rather than requiring them to press guess
        for i in 0 ... answer.count-1 {
            if guessedLetterLabels[i].text! != " " {
                guess += guessedLetterLabels[i].text!
            }
        }
        
        // Check guess string against answer string
        if guess == answer {
            correctGuessLabel.isHidden = false
            score+=1
            scoreLabel.text = "Score: " + String(score)
            // TODO: give guesser 1 point
            // TODO: transition to next round
            // TODO: notify everyone by displaying "Correct Guess by <device_name>!" on all screens
        } else {
            incorrectGuessLabel.isHidden = false
            guess = ""
        }
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
