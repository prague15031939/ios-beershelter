//
//  styleUtils.swift
//  BeerShelter
//
//  Created by NASTUSYA on 3/9/21.
//

import Foundation
import UIKit

class styleUtils : UIViewController {
    static func showError(_ msg: String, label: UILabel) {
        label.alpha = 1
        label.text = msg
    }

    static func styleLabel(_ label: UILabel) {
        let font=UserDefaults.standard.string(forKey: "fontStyle")
        let size=UserDefaults.standard.integer(forKey: "fontSize")
        let color=UserDefaults.standard.string(forKey: "fontColor")
        label.textColor = UIColor(named: color!)
        label.font = UIFont(name: font!, size: CGFloat(size))
    }
    
    static func styleTextView(_ text: UITextView) {
        let font=UserDefaults.standard.string(forKey: "fontStyle")
        let size=UserDefaults.standard.integer(forKey: "fontSize")
        let color=UserDefaults.standard.string(forKey: "fontColor")
        text.textColor = UIColor(named: color!)
        text.font = UIFont(name: font!, size: CGFloat(size))
    }
    
    static func styleActivityIndicator(_ indicator: UIActivityIndicatorView) {
        let color=UserDefaults.standard.string(forKey: "fontColor")
        indicator.color = UIColor(named: color!)
    }
    
}
