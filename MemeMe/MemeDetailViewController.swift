//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 8/23/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    let meme: Meme
    private let imageView = UIImageView()
    
    init(meme: Meme) {
        self.meme = meme
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(imageView)

        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = meme.memedImage
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
    }
    
    @objc
    func editTapped() {
        let memeEditorVC = UINavigationController(rootViewController: MemeEditorViewController(meme: meme))
        memeEditorVC.modalPresentationStyle = .fullScreen
        present(memeEditorVC, animated: true, completion: nil)
    }
}
