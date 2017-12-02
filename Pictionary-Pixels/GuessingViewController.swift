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
  @IBOutlet var guessedLetterLabels: [UILabel]!
  @IBOutlet var letterButtons: [UIButton]!
  
  override func viewDidLoad() {
      super.viewDidLoad()

    let answer = "hello"
    let alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y","z"]
    
    // Do any additional setup after loading the view.
    
    // generating keyboard
    var counter: Int = 0
    
    var slots = [Int]()
    var lettersAlreadyOnBoard = [String]()
    
    // For every letter in the answer assign it a random position on the board
    while counter < answer.count {
        let letter = String(answer[answer.index(answer.startIndex, offsetBy: counter)])
        let num = arc4random_uniform(14)
    
        // 1:1, slot number stored in slots[], actual char stored in lettersAlreadyOnBoard[]
        if !slots.contains(Int(num)) {
            lettersAlreadyOnBoard.append(letter)
            slots.append(Int(num))
            counter+=1
        }
    }
    
    counter = 0
    
    // For every slot, assign the letterButtons to the char determined in above loop
    for i in 0 ... slots.count-1 {
        letterButtons[slots[i]].setTitle(String(lettersAlreadyOnBoard[i]), for: UIControlState.normal)
    }
    
    // Fill in remaining empty slots with random letters
    // We allow duplicate/triplicate/multiples of letters, because it's random
    while counter < 14 {
        if !slots.contains(counter) {
            let chosenLetter = alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(26)))]
            lettersAlreadyOnBoard.append(chosenLetter)
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
  
  @IBAction func enterLetter(_ sender: Any) {
  }
  
  @IBAction func deleteLetter(_ sender: Any) {
  }
  
  @IBAction func clear(_ sender: Any) {
  }
  
  @IBAction func sendGuess(_ sender: Any) {
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
