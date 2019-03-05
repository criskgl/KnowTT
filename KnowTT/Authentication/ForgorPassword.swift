//
//  ForgorPassword.swift
//  KnowTT
//
//  Created by CK on 04/03/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import SCLAlertView

class ForgotPassword: UIViewController {
    @IBOutlet weak var emailUser: UITextField!
    @IBOutlet weak var sendEmailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        sendEmailButton.layer.cornerRadius = 15
        //Functionality to hide Keyboard
        self.hideKeyboardWhenTappedAround() 
    }
    @IBAction func sendResetEmailTouched(_ sender: Any) {
        guard //check for blank input
            emailUser.text!.count > 0
            else{
                SCLAlertView().showWarning("Please provide your email", subTitle: "")
                return
            }
        guard
            isValidEmail(testStr: emailUser.text!)
         == true
        else{
            SCLAlertView().showWarning("Not a ucsb.edu email", subTitle: "")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailUser.text!) { error in
            if error != nil {//ERROR
                SCLAlertView().showError("Error sending password reset email", subTitle: "The email provided might not be in our database")
            }else{
                SCLAlertView().showSuccess("Email to reset password sent", subTitle: "")
            }
        }
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@ucsb+\\.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
