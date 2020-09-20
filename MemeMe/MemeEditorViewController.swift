//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 5/20/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit

// MARK: - UITextField extension

private extension UITextField {
    static var meme: UITextField {
        let textField = UITextField(frame: .zero)
        let font = UIFont(name: "Impact", size: 40)!
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        textField.defaultTextAttributes = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: font,
            .strokeWidth: -5,  // negative to stroke and fill
            .paragraphStyle: paragraphStyle,
        ]
        textField.autocapitalizationType = .allCharacters
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }
}

// MARK: - MemeEditorViewController declaration

class MemeEditorViewController: UIViewController {
    let meme: Meme
    
    var imageObserver: NSKeyValueObservation?
    
    convenience init() {
        let defaultMeme = Meme(topText: "TOP", bottomText: "BOTTOM", originalImage: nil, memedImage: nil)
        self.init(meme: defaultMeme)
    }
    
    init(meme: Meme) {
        self.meme = meme
        super.init(nibName: nil, bundle: nil)
        
        imageObserver = observe(\.imageView.image) { [unowned self] object, _ in
            if object.imageView.image == nil {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lazy Properties
    
    @objc
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = meme.originalImage
//        iv.backgroundColor = .white
        return iv
    }()
    
    lazy var topTextField: UITextField = {
        let textField = UITextField.meme
        textField.text = meme.topText.uppercased()
        textField.delegate = self
        return textField
    }()
    
    lazy var bottomTextField: UITextField = {
        let textField = UITextField.meme
        textField.text = meme.bottomText.uppercased()
        textField.delegate = self
        return textField
    }()
    
    lazy var memeView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topTextField, UIView(), UIView(), bottomTextField])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.white.cgColor
        return stackView
    }()
    
    // MARK: TabBarItems
    
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
    
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    
    // MARK: UIViewController lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(imageView)
        
        imageView.frame = view.bounds
//        imageView.autoresizingMask = [.fle, .flexibleHeight]
        
        view.addSubview(memeView)

        memeView.translatesAutoresizingMaskIntoConstraints = false
        portraitConstraints = [
            memeView.widthAnchor.constraint(equalTo: memeView.heightAnchor),
            memeView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            memeView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            memeView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ]
        landscapeConstraints = [
            memeView.widthAnchor.constraint(equalTo: memeView.heightAnchor),
            memeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            memeView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            memeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ]

        activateCurrentConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action, target: self, action: #selector(presentShareSheet))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel", style: .plain, target: self, action: #selector(dismissEditor))
        
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        imageView.image = imageView.image
        
        self.navigationController?.isToolbarHidden = false
        self.toolbarItems = [
            cameraButtonItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            albumButtonItem,
        ]
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panImage(_:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage(_:)))
        panGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        view.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func activateCurrentConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
        if traitCollection.verticalSizeClass == .regular {
            // Portrait
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            // Landscape
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        activateCurrentConstraints()
        imageView.center = view.center
    }
    
    @objc
    func dismissEditor() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Image pan and zoom functions
    
    private var initialCenter = CGPoint()
    @objc
    func panImage(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)

        if gestureRecognizer.state == .began {
            initialCenter = imageView.center
        }
        if gestureRecognizer.state != .cancelled {
            imageView.center = CGPoint(
                x: initialCenter.x + translation.x,
                y: initialCenter.y + translation.y)
        } else {
            imageView.center = initialCenter
        }
    }
    
    @objc
    func zoomImage(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let scale = gestureRecognizer.scale
            imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
            gestureRecognizer.scale = 1.0
        }
    }
    
    // MARK: Image picker
    
    @objc
    func presentImagePicker(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sender.tag == 1 ? .camera : .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Share
    
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
    
    func save() {
        // update the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        
        // add it to the memes array in the application delegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
        
        print("saved meme: \(meme)")
    }
    
    func generateMemedImage() -> UIImage {
        // Render view to an image
        UIGraphicsBeginImageContext(memeView.bounds.size)
        let rect = memeView.bounds.insetBy(dx: -memeView.frame.minX, dy: -memeView.frame.minY)
        view.drawHierarchy(in: rect, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    // MARK: Keyboard hide/show behavior
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                // This check is necessary, since this notification is sent at every keypress when using the keyboard
                // on the simulator
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= frame.height
                }
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        // reset view when keyboard is dismissed while bottom textfield is selected
        // no need to check that bottomTextField.isFirstResponder here
        view.frame.origin.y = 0
    }
}

// MARK: - UIGestureRecognizerDelegate methods

extension MemeEditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // This method allows the pinch and pan gestures to work simultaneously
        true
    }
}

// MARK: - UIImagePickerDelegate methods

extension MemeEditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            imageView.center = view.center
        }
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate methods

extension MemeEditorViewController: UINavigationControllerDelegate {
    
}

// MARK: - UITextfieldDelegate methods

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
