//
//  MemeEditorViewController.swift
//  MemeMeV1
//
//  Created by Ramaiah  Indudhara on 8/16/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate, UIToolbarDelegate {
    
    // MARK: UI Elements
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoAlbumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar1: UIToolbar!
    @IBOutlet weak var toolBar2: UIToolbar!

    
    // MARK: Load View
    
    func addAttributesToView(_ textField: UITextField) {
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0]
        
        textField.defaultTextAttributes = memeTextAttributes
        
        textField.textAlignment = .center
        
        textField.text = "TYPE TO EDIT"
        myImage.image = nil
        shareButton.isEnabled = false                   // Disable share button initially (until user has inputted an image)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        addAttributesToView(topTextField)
        addAttributesToView(bottomTextField)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let memes = appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)         // disable camera if unable on device
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()              // move keyboard up
        subscribeToKeyboardNotificationsToMoveDown()    // move keyboard down
        
        self.tabBarController?.tabBar.isHidden = true   // hide tab bar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    
    // MARK: Image Picker
    
    
    @IBAction func imageFromCamera(_ sender: Any) {
        
        getImage(1)
    }
    
    @IBAction func imageFromAlbum(_ sender: Any) {
     
     getImage(0)
    }
    
    func getImage(_ num: Int){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if num == 1 {
            pickerController.sourceType = UIImagePickerControllerSourceType.camera
        }
        else {
            pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImage.contentMode = .scaleAspectFit
            myImage.image = pickedImage
            
            shareButton.isEnabled = true                    // Enable share button when the user has selected an image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Move Keyboard Up

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromKeyboardNotificationsToMoveDown()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    // When the keyboardWillShow notification is received, shift the view's frame up
    func keyboardWillShow(_ notification:Notification) {
        
        if topTextField.isEditing{
             view.frame.origin.y -= 70
        }
        
        if bottomTextField.isEditing {
              view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Move Keyboard Down

    func subscribeToKeyboardNotificationsToMoveDown() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotificationsToMoveDown() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide(_ notification:Notification){
        
            view.frame.origin.y = 0
    }
    
    // MARK: Cancel Meme Sketch
    
    @IBAction func cancelMemeSketch(_ sender: Any) {
        
        self.viewDidLoad()
    }
    
    
    // MARK: Create the Meme
    
    func hideToolBars(_ val: Bool){
        
        toolBar1.isHidden = val
        toolBar2.isHidden = val
    }
    
    func generateMemedImage() -> UIImage {
        
        hideToolBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    
        hideToolBars(false)
        
        return memedImage
    }
    
    func allMemePropertiesPresent(_ textField1: UITextField, textField2: UITextField, image: UIImage) -> Bool {
        
        if (textField1 == nil && textField2 == nil)
        {
            return false
        }

        if(image == nil)
        {
            return false
        }
        return true
    }
    
    func save() {
        
        if(allMemePropertiesPresent(topTextField, textField2: bottomTextField, image: myImage.image!))
        {
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: myImage.image!, memedImage: generateMemedImage())
            // Add it to the memes array in the Application Delegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.append(meme)
        }
        else
        {
            print("not all properties present")
        }
    }
    
    @IBAction func share(_ sender: Any) {
        
        let myMeme = generateMemedImage()
        let memedImageArray = [myMeme]
        
        let activityView = UIActivityViewController(activityItems: memedImageArray, applicationActivities: nil)
        present(activityView, animated: true, completion: nil)
        print("activity view present")
        activityView.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
}

