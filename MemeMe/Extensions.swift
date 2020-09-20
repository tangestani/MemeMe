//
//  Extensions.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 8/25/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

extension UIFont {
    static func list() {
        for family in familyNames.sorted() {
            let names = fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
}
