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

class RegisterSignView: UIViewController {
    //Outlets
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //Actions from Storyboard
    @IBAction func signInTouched(_ sender: Any) {
        guard
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                self.createAlert(title: "Invalid entry ", message: "Please fill all the fields")
                return
            }
        
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
    }
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
}

