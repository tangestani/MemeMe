//
//  Meme.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 5/24/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage?
    var memedImage: UIImage?
}

// Memes obtained from https://imgflip.com/memegenerator/
let sampleMemes = [
    Meme(topText: "ONE DOES NOT SIMPLY", bottomText: "WALK INTO MORDOR", originalImage: #imageLiteral(resourceName: "One-Does-Not-Simply"), memedImage: #imageLiteral(resourceName: "One-Does-Not-Simply")),
    Meme(topText: "NOT SURE IF EVERYTHING IS EXPENSIVE", bottomText: "OR I AM JUST POOR", originalImage: #imageLiteral(resourceName: "Futurama-Fry"), memedImage: #imageLiteral(resourceName: "Futurama-Fry")),
    Meme(topText: "Y U NO", bottomText: "SOCIAL DISTANCE", originalImage: #imageLiteral(resourceName: "Y-U-No.jpg"), memedImage: #imageLiteral(resourceName: "Y-U-No")),
    Meme(topText: "IF 2020 COULD JUST END", bottomText: "THAT WOULD BE GREAT", originalImage: #imageLiteral(resourceName: "That-Would-Be-Great.jpg"), memedImage: #imageLiteral(resourceName: "That-Would-Be-Great.jpg")),
    Meme(topText: "WHEN I BEAT THE COMPUTER IN CHESS ON EASY", bottomText: "WISE I AM", originalImage: #imageLiteral(resourceName: "Star-Wars-Yoda"), memedImage: #imageLiteral(resourceName: "Star-Wars-Yoda")),
    Meme(topText: "WHAT IF I TOLD YOU", bottomText: "THAT TOMATOES ARE BERRIES", originalImage: #imageLiteral(resourceName: "Matrix-Morpheus.jpg"), memedImage: #imageLiteral(resourceName: "Matrix-Morpheus.jpg")),
]
