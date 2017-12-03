//
//  ViewController.swift
//  Pictionary-Pixels
//
//  Created by Katrina Wijaya on 11/6/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    // Passed in from PointsView
    var multipeerService: MultipeerServiceManager!
    var rounds: Any!

    // MARK: Properties

    // where the drawing is
    @IBOutlet weak var mainImageView: UIImageView!

    // 9 buttons for drawing
    @IBOutlet weak var blackButton: GameButton!
    @IBOutlet weak var redButton: GameButton!
    @IBOutlet weak var orangeButton: GameButton!
    @IBOutlet weak var yellowButton: GameButton!
    @IBOutlet weak var greenButton: GameButton!

    @IBOutlet weak var blueButton: GameButton!
    @IBOutlet weak var magentaButton: GameButton!
    @IBOutlet weak var brownButton: GameButton!
    @IBOutlet weak var eraserButton: GameButton!

    var lastButtonHit: GameButton?

    // TODO: pointsLabel, timer
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
    // TODO: Keep this updated on first entry
    @IBOutlet weak var currentWordLabel: UILabel!
    var seconds = 30
    var timer = Timer()
    
    // For continuous brush strokes
    // Store last point drawn
    var lastPoint = CGPoint(x: 0, y: 0)
    
    // Current color and brush size
    var currColor: CGColor = UIColor.black.cgColor
    var brushWidth: CGFloat = 8.0
    
    // Are continous strokes being made
    var swiped = false
    
    // Answer string supplied by guessing view
  
    // Assuming this stays same for both views, across app lifecycle, set in viewDidLoad
    // TODO: check that the guessing/drawing views are the same size, looks a little off
    var viewFrameSize: CGSize?

    // MARK: Touch Handlers

    // Override parent interface (UIVC implements) UIResponder's touchesBegan function
    // Called when finger put on screen (like keyPressed)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Reset swiped
        // Indicates that drawing hasn't started yet
        swiped = false
        
        // Should be a set of touches when this happens
        // Save location in lastPoint
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }

        // Send new point being drawn to all peers
        let dictionary:NSDictionary = ["new_point": NSValue(cgPoint: lastPoint)]
        multipeerService.sendMessage(message: dictionary)
    }
  
    // As finger moves, we draw line between every new point sensed and last point
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If there is a current swipe in progress
        swiped = true
        
        // Drawing lines from last point to current point
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLine(from: lastPoint, to: currentPoint)

            // Send current point to all peers (they will call drawLine themselves)
            let dictionary:NSDictionary = ["current_point": NSValue(cgPoint: currentPoint)]
            multipeerService.sendMessage(message: dictionary)

            // Make sure to update last point
            lastPoint = currentPoint
        }
    }
  
    // When touch ends, stop drawing
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Finger didn't move, so draw 1 point only
        if !swiped {
            drawLine(from: lastPoint, to: lastPoint)

            // Send last point to all peers
            let dictionary:NSDictionary = ["last_point": NSValue(cgPoint: lastPoint)]
            multipeerService.sendMessage(message: dictionary)
        }
    }
  
    // DRAWING MAGIC
    // Draws line between 2 points
    func drawLine(from p1: CGPoint, to p2: CGPoint) {
        // Starts empty, want to draw into mainImageView
        // CGContext = 2D drawing environment, with drawing parameters / device info
        // Needed to render drawing correctly for destination (e.g. app window, PDF)
        guard let frameSize = viewFrameSize else {
            print("draw Size of view frame not initialized yet!")
            return
        }
        
        UIGraphicsBeginImageContext(frameSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("No image context to draw to!")
            return
        }
        
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))

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
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
  
  // MARK: Default Functions
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        viewFrameSize = mainImageView.frame.size
        //runTimer()
        self.multipeerService.delegate = self
        
        // TODO: initialize this in points view, or hopefully get this updated when drawer loads before guesser does (everytime guesser loads, updates answer
        currentWordLabel.text = answer
        winnerLabel.isHidden = true
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: - Actions
  
    // When color button is pressed, handle settings changes
    @IBAction func colorPressed(_ sender: AnyObject) {
        // Make sure lastButtonHit is initialized
        if lastButtonHit == nil {
            lastButtonHit = blackButton
        }

        // Set color values
        if let colorButton = sender as? GameButton, let backColor = colorButton.backgroundColor {
            // Check button's label instead of background color
            // For example, our custom "Black" is NOT same as UIColor.black
            if colorButton.currentTitle == "Eraser" {
                brushWidth = 25
            } else {
                // See if color picked is dark enough to have a light border
                // Otherwise border color is black
                var pickedBright: CGFloat = 0
                if backColor.getHue(nil, saturation: nil, brightness: &pickedBright, alpha: nil), pickedBright < 0.6 {
                    colorButton.borderColor = UIColor(red: 0, green: 150.0/255, blue: 1, alpha: 1)
                } else {
                    colorButton.borderColor = UIColor.black
                }
                
                brushWidth = 8
            }
            colorButton.borderWidth = 3
            
            // Where actual stroke color is set
            currColor = backColor.cgColor
            
            // Send peers stroke color and brush width
            let dictionary:NSDictionary = ["brush_width": brushWidth, "stroke_color": "currColor"]
            multipeerService.sendMessage(message: dictionary)
            
            // Deselect last selected color, unless that is same as current
            if let lastColB = lastButtonHit, lastColB != colorButton {
                // Set last's border to nothing if was normal color, to width 1 if was Eraser
                lastColB.borderWidth = lastColB.currentTitle != "Eraser" ? 0 : 1
            }
            
            lastButtonHit = colorButton
        }
    }
  
  @IBAction func clear(_ sender: Any) {
      self.mainImageView.image = nil;
    
    let dictionary:NSDictionary = ["reset": "true"]
    multipeerService.sendMessage(message: dictionary)
  }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(GuessingViewController.updateTimer)), userInfo: nil, repeats: true)
    }

    func updateTimer() {
        if (seconds < 1) {
            timer.invalidate()
            DispatchQueue.main.async() {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "DrawingView")
                self.present(newViewController, animated: true, completion: nil)
            }
        } else {
            seconds -= 1
            timeLeftLabel.text = ":\(seconds)"
        }
    }
    
    // Transition back to points view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DrawingToPointsSegue") {
            if let dest = segue.destination as? PointsViewController {
                dest.multipeerService = multipeerService
            }
        }
        if (segue.identifier == "DrawingToGuessing") {
            if let dest = segue.destination as? GuessingViewController {
                dest.multipeerService = multipeerService
            }
        }
    }
}
    
extension DrawingViewController: MultipeerServiceManagerDelegate {
    func messageReceived(manager: MultipeerServiceManager, message: NSDictionary) {
        print("REACHED DRAWING VIEW MESSAGE RECEIVED")
        print("MESSAGE CONTAINS: ")
        print(message)
        OperationQueue.main.addOperation {
            print("INSIDE OPERATION QUEUE")
            // Messages from guessers
            if let newAnswer = message["answer"] {
                print("NEW DRAWERS ANSWER \(answer) \n \n")
                answer = newAnswer as! String
            }
            
            if message["newRound"] != nil {
                self.currentWordLabel.text = answer
                print("LABEL \(answer) \n \n")
                self.mainImageView.image = nil
            }
            
            if message["gameOver"] != nil {
                self.clear(self)
                self.winnerLabel.isHidden = false
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Transition to Points view
                    self.performSegue(withIdentifier: "DrawingToPointsSegue", sender: self)
                }
            }
            
            if message["updateIndex"] != nil {
                drawerIndex = message["updateIndex"] as! Int
                self.currentWordLabel.isHidden = true
                self.performSegue(withIdentifier: "DrawingToGuessing", sender: self)
            }
        }
    }
    
        func connectedDevicesChanged(manager: MultipeerServiceManager, connectedDevices: [String]) {
            OperationQueue.main.addOperation {
                // do nothing
            }
        }
}

