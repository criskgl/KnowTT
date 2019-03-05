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
import JGProgressHUD
import SwiftSocket

class RegisterView: UIViewController{
    
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var verifyEmailButton: UIButton!
    
    var userRegistered = ""
    
    //Essence of client
    var client: TCPClient?
    
    @IBOutlet weak var registerButton: UIButton!
    
    //Prepare to change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style:UIStatusBarStyle = .default
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fucntionality to hide keyboard
        self.hideKeyboardWhenTappedAround()
        //Styling Register Butoon
        registerButton.layer.cornerRadius = 15
        //Style status bar
        self.style = .lightContent
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        verifyEmailButton.isHidden = true
    }
    
    
    @IBAction func goToLogin(_ sender: Any) {
        self.performSegue(withIdentifier: "registerToSignRegister", sender: self)
    }
    
    @IBAction func submitRegistration(_ sender: UIButton) {
        
        let email = userMail.text!
        
        let password = userPassword.text!
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Adding New Member..."
        hud.show(in: self.view)
        registerUser(email, password)
        hud.dismiss(afterDelay: 1.0)
    }
    
    func registerUser(_ email:String, _ password:String){
        //Control the input is not blank
        guard
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                SCLAlertView().showWarning("Invalid entry", subTitle: "Please fill all the fields. Password has to be at least 6 characters")
                return
        }
        guard
            isValidEmail(testStr: email) == true
            else {
                SCLAlertView().showWarning("Invalid Email", subTitle: "You need to have a UCSB email to register")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            /*
            if error == nil {//sign in outomatically after registering
                Auth.auth().signIn(withEmail: self.userMail.text!,
                                   password: self.userPassword.text!)
            }
            */
            if error != nil{//ERROR REGISTERING USER
                SCLAlertView().showError("Registration Error", subTitle: "There has been a problem adding new member. Check if you already have a KnowT account")
            }else{//NO ERROR REGISTERING USER
                //notify registration of own servers
                let registerRequest = UserNote()
                registerRequest.buildNote("REGISTER", Auth.auth().currentUser!.email!, "", "", "")
                let json = registerRequest.getJson()
                let dataToSend = "\(json)"
                //let response = self.sendJson(self, dataToSend)
                //print("RESPONSE FROM SERVER AFTER REGSITER: ", response)
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if error != nil { //ERROR
                        SCLAlertView().showError("Email Verification", subTitle: "We could not send the verification email")
                    }else{//NO ERROR
                        //Tell user to verify email
                        SCLAlertView().showInfo("Verification email  Sent", subTitle: "")
                        //Show user that the registration has been completed
                        SCLAlertView().showSuccess("Registration Success", subTitle: "You just need to verify your email to sign in")
                        self.verifyEmailButton.isHidden = false
                    }
                }
                
            }
            // ...
            guard (authResult?.user) != nil else { return }
        }
        //clean up for future ocassions
        userMail.text = ""
        userPassword.text = ""
    }
    
    
    @IBAction func verifyEmailTouched(_ sender: Any) {
        self.sendVerificationEmail()
    }
    
    @objc private func sendVerificationEmail(){
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil { //ERROR
                SCLAlertView().showWarning("Email Verification", subTitle: "A verification email has been already sent to \(Auth.auth().currentUser!.email ?? "")")
            }else{//NO ERROR
                SCLAlertView().showInfo("Verification Email sent", subTitle: "Follow the link we sent to \(Auth.auth().currentUser!.email ?? "") to verify your account")
            }
        }
    }
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //NETWORKING FUNCTIONS
    func sendJson(_ sender: Any, _ jsonString: String) -> String{
        
        if let response = sendData(string: jsonString, using: client!){
            print("Result from server: ", response)
            print("Response: \(response)")
            return response
        }
        return "[ERROR][sendJson]"
    }
    
    //uses readResponse
    private func sendData(string: String, using client: TCPClient) -> String? {
        print("Iphone Sending Data . . .")
        switch client.send(string: string) {
        case .success:
            print("The data has been succesfully sent")
            return readResponse(from: client) //This is returning the string read from server
        case .failure(let error):
            print(String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10, timeout: 10) else {return nil}
        return String(bytes: response, encoding: .ascii)
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@ucsb+\\.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
