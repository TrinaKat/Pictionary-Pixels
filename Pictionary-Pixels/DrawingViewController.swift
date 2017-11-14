//
//  ViewController.swift
//  Pictionary-Pixels
//
//  Created by Katrina Wijaya on 11/6/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

// IBInspectable allows you to add custom attributes to Interface Builder!
// now all buttons have an option for corner radius, border width and color
// IBDesignable renders these custom attribute changes in the storyboard live
// for this to work, buttons in the app must be of class GameButton (set in IB)
@IBDesignable
class GameButton: UIButton {
  // didSet means this variable actually defined by a setter function,
  // called when cornerRadius is changed (from IB in this case)
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      layer.cornerRadius = cornerRadius
      layer.masksToBounds = cornerRadius > 0
    }
  }
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  @IBInspectable var borderColor: UIColor? {
    didSet {
      layer.borderColor = borderColor?.cgColor
    }
  }
}

class DrawingViewController: UIViewController {

  // MARK: Properties
  
  // 2 image views: main = all drawn so far, temp = current line being drawn
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!
  
  // for making continuous brush strokes, store last point drawn
  var lastPoint = CGPoint(x: 0, y: 0)
  // current selected color and other settings
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 0.0
  var brushWidth: CGFloat = 10.0
  var opacity: CGFloat = 1.0
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
    
    // not sure if mainImageView's frame and UIVC's frame are different sizes
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    guard let frameSize = viewFrameSize else {
      print("size of view frame not initialized yet!")
      return
    }
    mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height), blendMode: CGBlendMode.normal, alpha: 1.0)
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height), blendMode: CGBlendMode.normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // reset the temp view, so only 1 stroke ever saved on temp image at a time
    tempImageView.image = nil
  }
  
  // DRAWING MAGIC
  func drawLine(from p1: CGPoint, to p2: CGPoint) {
    // set up drawing context with image in tempImageView
    // starts empty, want to draw into tempImageView
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
    tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height))
    
    // add the line data to context from p1 to p2 (p1, p2 very close together)
    context.move(to: p1)
    context.addLine(to: p2)
    
    // other settings for drawing
    context.setLineCap(CGLineCap.round)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
    context.setBlendMode(CGBlendMode.normal)
    
    // MAGIC METHOD to actually form the line
    context.strokePath()
    
    // wrap up drawing context, render newly drawn line in tempImageView
    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    tempImageView.alpha = opacity
    UIGraphicsEndImageContext()
  }
  
  // MARK: Default Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewFrameSize = view.frame.size
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Actions
  
  @IBAction func reset(_ sender: AnyObject) {
  }
  
  @IBAction func share(_ sender: AnyObject) {
  }
  
  @IBAction func pencilPressed(_ sender: AnyObject) {
  }
}

