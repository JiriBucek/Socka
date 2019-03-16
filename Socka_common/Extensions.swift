//
//  Extensions.swift
//  Socka
//
//  Created by Boocha on 16.03.19.
//  Copyright © 2019 Boocha. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    // Vytvoření barvy dle HEX kodu. 
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0

        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
        
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}
