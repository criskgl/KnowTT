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
    
    var userRegistered = ""
    
    //Essence of client
    var client: TCPClient?
    
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
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Adding New Member..."
        hud.show(in: self.view)
        registerUser(email, password)
        hud.dismiss(afterDelay: 1.0)
    }
    
    @IBAction func cancelTouched(_ sender: Any) {
                self.performSegue(withIdentifier: "registerToSignRegister", sender: self)
    }
    func registerUser(_ email:String, _ password:String){
        //Control the input is not blank
        guard
            let email = userMail.text,
            let password = userPassword.text,
            email.count > 0,
            password.count > 0
            else {
                self.createAlert(title: "Invalid entry", message: "Please fill all the fields. Password at least 6 characters")
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
            if error != nil{
                SCLAlertView().showError("Registration Error", subTitle: "There has been a problem adding new member. Check that you dont already have a KnowT account")
            }else{
                //notify registration of own servers
                let registerRequest = UserNote()
                registerRequest.buildNote("REGISTER", Auth.auth().currentUser!.email!, "", "", "")
                let json = registerRequest.getJson()
                let dataToSend = "\(json)"
                //let response = self.sendJson(self, dataToSend)
                //print("RESPONSE FROM SERVER AFTER REGSITER: ", response)
                SCLAlertView().showSuccess("Registration Success!", subTitle: "")
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
