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
import SCLAlertView




class RegisterSignView: UIViewController {
    //Outlets
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var emailToVerify = ""
    var passToVerify = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Functionality to hide Keyboard
        self.hideKeyboardWhenTappedAround() 
        //Styling Buttons Sign In and Register
        registerButton.layer.cornerRadius = 15
        signInButton.layer.cornerRadius = 15
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true)
        Auth.auth().currentUser?.reload()
        
        #warning ("used for testing purposes")
        if(Auth.auth().currentUser?.email == nil){
            print("Firebase Debug: No user connected")
        }else{
            print("Firebase Debug: user \(Auth.auth().currentUser!.email!) is connected")
        }
    }
    //Actions from Storyboard

    
    @IBAction func signInTouched(_ sender: Any) {
        guard //Take care of not long enough
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                SCLAlertView().showWarning("Invalid entry", subTitle: "Please fill all the fields")
                return
            }
        //Reload user data in Firebase
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true)
        Auth.auth().currentUser?.reload()
    
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Signing in..."
        hud.show(in: self.view)
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                //Firebase Sign in Failed
                SCLAlertView().showError("Error Signing in", subTitle: error.localizedDescription)
            }else{
                //Firebase Sign in Success
                //--Check if email has been verified
                guard //Take care of unverified users
                    Auth.auth().currentUser?.isEmailVerified == true
                    else {
                    //--If email not verified
                        let emailNotVerifiedAlert = SCLAlertView()
                        //save values to entered to later send the verification email
                        self.passToVerify = self.userPassword.text!
                        self.emailToVerify = self.userMail.text!
                        
                        emailNotVerifiedAlert.addButton("Send Verification E-mail") {
                            //self.performSegue(withIdentifier: "toForgotPasswordView", sender: self)
                            sendVerificationEmail(withEmail: self.emailToVerify, withPassword: self.passToVerify)
                        }
                        emailNotVerifiedAlert.showWarning("E-mail verification required", subTitle: "If you have already verified it try again in 5 seconds")
                    //Sign out the user from firebase
                        try! Auth.auth().signOut()
                    return
                }
                //--Email has been verified
                //Go to user home
                self.performSegue(withIdentifier: "RegisterSignToUserHome", sender: self)
            }
        }
        hud.dismiss()
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
//Function to send verification email
private func sendVerificationEmail(withEmail email: String, withPassword password: String){
    Auth.auth().signIn(withEmail: email, password: password) { user, error in
        if let error = error, user == nil {//--Firebase Sign in Failed
            SCLAlertView().showError("Error Signing in", subTitle: error.localizedDescription)
        }else{//--Firebase Sign in Success
            //Send verification email
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                if error != nil { //ERROR
                    SCLAlertView().showError("Email Verification", subTitle: "There has been an error sending the verification E-mail")
                }else{//NO ERROR
                    //Verification email sent successfully
                    SCLAlertView().showInfo("Verification email  sent", subTitle: "Check your inbox to find the verification E-mail")
                }
            }
        }
    }
}

