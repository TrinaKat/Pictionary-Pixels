//
//  ViewController.swift
//  Pictionary-Pixels
//
//  Created by Katrina Wijaya on 11/6/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {

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
  
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var timeLeftLabel: UILabel!
  @IBOutlet weak var currentWordLabel: UILabel!

  var seconds = 30
  var timer = Timer()
  // for making continuous brush strokes, store last point drawn
  var lastPoint = CGPoint(x: 0, y: 0)
  // current selected color and other settings
  var currColor: CGColor = UIColor.black.cgColor
  var brushWidth: CGFloat = 8.0
  // if continous strokes being made
  var swiped = false
  
  // assuming this stays same for both views, across app lifecycle, set in viewDidLoad
  var viewFrameSize: CGSize?
  
  // MARK: Touch Handlers
  
  // override parent interface (UIVC implements) UIResponder's touchesBegan function
  // called when finger put on screen (like keyPressed)
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    swiped = false      // reset swiped, drawing hasn't started yet
    // should be a set of touches when this happens, save location in lastPoint
    if let touch = touches.first {
      lastPoint = touch.location(in: self.view)
    }
  }
  
  // as finger moves, we draw line between every new point sensed and last point
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    swiped = true     // if there is current swipe in progress
    if let touch = touches.first {
      let currentPoint = touch.location(in: self.view)
      drawLine(from: lastPoint, to: currentPoint)
      // make sure to update last point
      lastPoint = currentPoint
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // didn't move, so draw 1 point only (since drawLine called in touchesMoved)
    if !swiped {
      drawLine(from: lastPoint, to: lastPoint)
    }
  }
  
  // DRAWING MAGIC
  func drawLine(from p1: CGPoint, to p2: CGPoint) {
    // starts empty, want to draw into mainImageView
    // CGContext = 2D drawing environment, with drawing parameters / device info
    // needed to render drawing correctly for destination (e.g. app window, PDF)
    guard let frameSize = viewFrameSize else {
      print("size of view frame not initialized yet!")
      return
    }
    UIGraphicsBeginImageContext(frameSize)
    guard let context = UIGraphicsGetCurrentContext() else {
      print("No image context to draw to!")
      return
    }
    mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
    
    // add the line data to context from p1 to p2 (p1, p2 very close together)
    context.move(to: p1)
    context.addLine(to: p2)
    
    // other settings for drawing
    context.setLineCap(CGLineCap.round)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(currColor)
    context.setBlendMode(CGBlendMode.normal)
    
    // MAGIC METHOD to actually form the line
    context.strokePath()
    
    // wrap up drawing context, render newly drawn line in mainImageView
    // basically captures what is put on screen into actual graphics and put in a view
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  // MARK: Default Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewFrameSize = mainImageView.frame.size
    runTimer()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Actions
  
  @IBAction func colorPressed(_ sender: AnyObject) {
    if lastButtonHit == nil {
      lastButtonHit = blackButton
    }
    
    if let colorButton = sender as? GameButton,
      let backColor = colorButton.backgroundColor {
      // check button's label instead of background color
      // for example, our custom "Black" is NOT same as UIColor.black
      if colorButton.currentTitle == "Eraser" {
        brushWidth = 25
      }
      else {
        // see if color picked is dark enough to have a light border
        var pickedBright: CGFloat = 0
        if backColor.getHue(nil, saturation: nil, brightness: &pickedBright, alpha: nil),
          pickedBright < 0.6 {
          colorButton.borderColor = UIColor(red: 0, green: 150.0/255, blue: 1, alpha: 1)
        }
        else {
          colorButton.borderColor = UIColor.black
        }
        brushWidth = 8
      }
      colorButton.borderWidth = 3
      
      // where actual stroke color is set
      currColor = backColor.cgColor
      // deselect last selected color, unless that is same as current
      if let lastColB = lastButtonHit,
        lastColB != colorButton {
        // set last's border to nothing if was normal color, to width 1 if was Eraser
        lastColB.borderWidth = lastColB.currentTitle != "Eraser" ? 0 : 1
      }
      lastButtonHit = colorButton
    }
  }
  
  @IBAction func clear(_ sender: Any) {
      self.mainImageView.image = nil;
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
}
