//
//  Color.swift
//  Material
//
//  Created by Truth on 2016. 1. 4..
//  Copyright © 2016년 Truth. All rights reserved.
//

import Foundation

struct Color {
    var RGB: String
    var memo: String
    var title: String
    var mainTitle: String
    
    init(){
        self.RGB = ""
        self.memo = ""
        self.title = ""
        self.mainTitle = ""
    }
    
    init(RGB: String, memo: String, title: String, mainTitle: String){
        self.RGB = RGB
        self.memo = memo
        self.title = title
        self.mainTitle = mainTitle
    }
}