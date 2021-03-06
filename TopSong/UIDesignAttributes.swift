//
//  UIDesignAttributes.swift
//  TopSong
//
//  Created by Eric Hodgins on 2016-06-12.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit


class UIDesign {
    
    class func lightStyleAttributedString(text: String, fontSize: CGFloat) -> NSAttributedString {
        let colorAttribute = UIColor().lightBlueAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: fontSize)
        
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
    }
    
    class func darkStyleAttributedString(text: String, fontSize: CGFloat) -> NSAttributedString {
        let colorAttribute = UIColor().darkBlueAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: fontSize)
        
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
    }
    
    class func highlightedAttributedString(text: String, fontSize: CGFloat) -> NSAttributedString {
        let colorAttribute = UIColor().redAppDesign
        let fontAttribute = UIFont.chalkboardFont(withSize: fontSize)
        
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
    }
    
    class func customColorStyleAttributedString(text: String, fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        let colorAttribute = color
        let fontAttribute = UIFont.chalkboardFont(withSize: fontSize)
        
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: fontAttribute, NSForegroundColorAttributeName: colorAttribute])
    }
}


extension UIColor {
    
    var lightBlueAppDesign: UIColor {
        return UIColor(red: 145/255, green: 187/255, blue: 212/255, alpha: 1.0)
    }
    
    var darkBlueAppDesign: UIColor {
        return UIColor(red: 80/255, green: 121/255, blue: 145/255, alpha: 1.0)
    }
    
    var redAppDesign: UIColor {
        return UIColor(red: 241/255, green: 73/255, blue: 73/255, alpha: 1.0)
    }
    
}

extension UIFont {
    class func chalkboardFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Chalkboard SE", size: size)!
    }
}
