//
//  ViewController.swift
//  UCSellB
//
//  Created by CK on 15/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Canvas
import SCLAlertView
import JGProgressHUD




class RegisterSignView: UIViewController {
    //Outlets
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Functionality to hide Keyboard
        self.hideKeyboardWhenTappedAround() 
        //Styling Buttons Sign In and Register
        registerButton.layer.cornerRadius = 15
        signInButton.layer.cornerRadius = 15
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true)
        Auth.auth().currentUser?.reload()
    }
    //Actions from Storyboard
    @IBAction func signInTouched(_ sender: Any) {
        guard //Take care of not long enough
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                self.createAlert(title: "Invalid entry ", message: "Please fill all the fields")
                return
            }
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true)
        Auth.auth().currentUser?.reload()
        guard //Take care of unverified users
            Auth.auth().currentUser!.isEmailVerified == true
            else {
                SCLAlertView().showWarning("Email Verification", subTitle:                 String(format: "Your email %@ has not yet been verified. If you already verified it, try again in 5 seconds", userMail.text ?? ""))
            return
        }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Signing in..."
        hud.show(in: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "RegisterSignToUserHome", sender: self)
            }
        }
        hud.dismiss(afterDelay: 2.0)
    }
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
}
// Extension to hide keyboard when touched anywhere
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

