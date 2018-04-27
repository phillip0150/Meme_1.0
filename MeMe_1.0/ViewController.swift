//
//  ViewController.swift
//  MeMe_1.0
//
//  Created by Phillip Valdez on 4/18/18.
//  Copyright © 2018 Phillip Valdez. All rights reserved.
//
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    //The meme
    var memedImage: UIImage!
    
    //Meme Text Attributes
    let memeTextAttributes:[String: Any] = [NSAttributedStringKey.strokeColor.rawValue: UIColor.black, NSAttributedStringKey.foregroundColor.rawValue: UIColor.white, NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSAttributedStringKey.strokeWidth.rawValue: -6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        
        isCameraEnable()
        setupTextField(textField: topText, text: "TOP")
        setupTextField(textField: bottomText, text: "BOTTOM")
        
        //Blank image
        imagePicker.image = UIImage(named: "Blank.png")
        
    }
    
    //Checking to see if camera is enabled
    func isCameraEnable() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = true
        }
        else{
            cameraButton.isEnabled = false
        }
    }
    
    //setting up text field with a UITextField and text for it
    func setupTextField(textField: UITextField, text: String) {
    
        textField.delegate = self
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        imagePicker.image = image
        dismiss(animated: true, completion: nil)
        }
    }

    //picking an image from the album
    @IBAction func pickImageAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true

    }
    
    //picking an image from the camera
    @IBAction func pickImageCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        shareButton.isEnabled = true
    }

    //genrating meme image
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        navBar.isHidden = true
        toolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        navBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    //saving meme
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePicker.image!, memedImage: memedImage)
    }
    
    
    //sharing meme:
    @IBAction func shareMeme(_ sender: Any) {
        //generate a memed image
        let theMeme = generateMemedImage()
        
        //define an instance of the ActivityViewController
        //pass the ActivityViewController a memedImage as an activity item
        let viewController = UIActivityViewController(activityItems: [theMeme], applicationActivities: [])
        
        //present the ActivityViewController
        present(viewController, animated: true, completion: nil)
        viewController.completionWithItemsHandler = { (activity, success, items, error) in
            if (success) {
                self.save(memedImage: theMeme)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //When a user presses cancel, it resets the view
    @IBAction func cancelMeme(_ sender: Any) {
        viewDidLoad()
    }
    
    //when the user presses return on the keyboard, it returns to the picture with the text
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //setting a blank string when a user clicks on the text filed
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
    }
    
    //Hiding and showing keyboard with subscribeToKeyboard
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder == true {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder == true {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    //over ride functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

