//
//  MainViewController.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 8/22/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tableVC = UINavigationController(
            rootViewController: SentMemesTableViewController())
        tableVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "table"), tag: 0)
        let collectionVC = UINavigationController(
            rootViewController: SentMemesCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        collectionVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "collection"), tag: 1)
        
        viewControllers = [tableVC, collectionVC]
    }
}
