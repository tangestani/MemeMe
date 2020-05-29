//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 5/20/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    @objc
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    static func applyTextFieldStyleProperties(textField: UITextField) {
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.adjustsFontSizeToFitWidth = true
        textField.defaultTextAttributes = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -5  // negative to stroke and fill
        ]
        // Add a small padding to the left side of the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    lazy var topTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        MemeEditorViewController.applyTextFieldStyleProperties(textField: textField)
        textField.text = "TOP"
        textField.delegate = self
        return textField
    }()
    
    lazy var bottomTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        MemeEditorViewController.applyTextFieldStyleProperties(textField: textField)
        textField.text = "BOTTOM"
        textField.delegate = self
        return textField
    }()
    
    lazy var cameraButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(presentImagePicker(sender:)))
        buttonItem.tag = 1
        buttonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        return buttonItem
    }()
    
    lazy var albumButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(title: "Album", style: .plain, target: self, action: #selector(presentImagePicker(sender:)))
        buttonItem.tag = 2
        buttonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        return buttonItem
    }()
    
    var observation: NSKeyValueObservation?
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action, target: self, action: #selector(presentShareSheet))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: nil, action: nil)
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [
            cameraButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            albumButtonItem,
        ]
        
        view.addSubview(imageView)
        
        imageView.frame = view.frame
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let stackView = UIStackView(arrangedSubviews: [topTextField, UIView(), bottomTextField])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        
        stackView.frame = view.frame
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        observation = imageView.observe(\.image) { [unowned self] iv, _ in
            if iv.image == nil {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- Image picker
    
    @objc
    func presentImagePicker(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sender.tag == 1 ? .camera : .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK:- Share
    
    @objc
    func presentShareSheet() {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { [unowned self] activityType, completed, returnedItems, activityError in
            if completed {
                self.save()
            }
        }
        present(activityVC, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    func save() {
        let memedImage = generateMemedImage()
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        print("saved meme: \(meme)")
    }
    
    // MARK:- Keyboard hide/show behavior
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        // move view up if keyboard appears while bottom textfield is selected
        if bottomTextField.isFirstResponder {
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                view.frame.origin.y -= frame.height
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        // reset view when keyboard is dismissed while bottom textfield is selected
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
}

// MARK:- UIImagePickerDelegate methods

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageView.image = image
        }
        dismiss(animated: true)
    }
}

// MARK:- UINavigationControllerDelegate methods

extension MemeEditorViewController: UINavigationControllerDelegate {
    
}

// MARK:- UITextfieldDelegate methods

extension MemeEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "BOTTOM" || textField.text == "TOP" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
