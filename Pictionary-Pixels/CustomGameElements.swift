//
//  GameButton.swift
//  Pictionary-Pixels
//
//  Created by Jason Xu on 11/30/17.
//  Copyright © 2017 TrinaKat. All rights reserved.
//

import UIKit

var devices: [String]?

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
  // borderWidth and Color change when button selected / deselected, from action method
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  @IBInspectable var borderColor: UIColor? {
    didSet {
      if let validColor = borderColor {
        layer.borderColor = validColor.cgColor
      }
      else {
        layer.borderColor = nil
      }
    }
  }
}

@IBDesignable
class GameLetter: UILabel {
  
  // borderWidth and Color change when button selected / deselected, from action method
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  @IBInspectable var borderColor: UIColor? {
    didSet {
      if let validColor = borderColor {
        layer.borderColor = validColor.cgColor
      }
      else {
        layer.borderColor = nil
      }
    }
  }
}
