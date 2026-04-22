//
//  UILabel+Ext.swift
//  Chess
//
//  Created by Ibrahim Kolchi on 17.02.26.
//

import UIKit

extension UILabel {
    convenience init(text: String) {
        self.init()
        self.text = text
        font = .boldSystemFont(ofSize: 22)
    }
}
