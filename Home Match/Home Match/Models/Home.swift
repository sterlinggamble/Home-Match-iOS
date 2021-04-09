//
//  Home.swift
//  Home Match
//
//  Created by Sterling Gamble on 4/4/21.
//

import Foundation

class Home {
    let imageURL: String?
    let address: String?
    let price: String?
    var score: Float = Float.greatestFiniteMagnitude
    
    init(imageURL: String, address:String, price: String) {
        self.imageURL = imageURL
        self.address = address
        self.price = price
    }
}


