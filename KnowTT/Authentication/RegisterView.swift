//
//  registerView.swift
//  UCSellB
//
//  Created by CK on 17/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import SCLAlertView

class RegisterView: UIViewController{
    
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var userRegistered = ""
    
    
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fucntionality to hide keyboard
        self.hideKeyboardWhenTappedAround()
        //Styling Register Butoon
        registerButton.layer.cornerRadius = 15
    }
    
    @IBAction func submitRegistration(_ sender: UIButton) {
        
        let email = userMail.text!
        
        let password = userPassword.text!
        
        registerUser(email, password)
        
    }
    
    @IBAction func cancelTouched(_ sender: Any) {
                self.performSegue(withIdentifier: "registerToSignRegister", sender: self)
    }
    func registerUser(_ email:String, _ password:String){
        //Control the input
        guard
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                self.createAlert(title: "Invalid entry", message: "Please fill all the fields. password at least 6 characters")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error == nil {//sign in outomatically after registering
                Auth.auth().signIn(withEmail: self.userMail.text!,
                                   password: self.userPassword.text!)
            }
            if error != nil{
                self.createAlert(title: "ERROR", message: "THERE HAS BEEN AN ERROR REGISTERING USER")
            }else{
                SCLAlertView().showSuccess(" Registration Success!", subTitle: "")
            }
            // ...
            guard (authResult?.user) != nil else { return }
            
        }
        //clean up for future ocassions
        userMail.text = ""
        userPassword.text = ""
    }
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
