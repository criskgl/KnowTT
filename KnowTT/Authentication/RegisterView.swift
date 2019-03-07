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

struct ACKRegisterDecodedStruct: Codable {
    var opCode: String
    var result: String
}

class RegisterView: UIViewController{
    
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userConfirmPassword: UITextField!
    
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
        //Invoking TCP client
        client = TCPClient(address: "142.93.204.52", port: 8080)
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
        
        registerUser(email, password)
        
    }
    
    func registerUser(_ email:String, _ password:String){
        //---All input controls passed
        //show loader
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Adding New Member..."
        hud.show(in: self.view)
        
        //Control the input is not blank
        guard
            let email = userMail.text,
            let password = userPassword.text,
            let passwordConfirmation = userConfirmPassword.text,
            email.count > 0,
            password.count > 0,
            passwordConfirmation.count > 0
            else {
                SCLAlertView().showWarning("Invalid entry", subTitle: "Please fill all the fields")
                //hide loader
                hud.dismiss()
                return
        }
        //Control it is a ucsb email
        guard
            isValidEmail(testStr: email) == true
            else {
                SCLAlertView().showWarning("Invalid Email", subTitle: "You need to have a UCSB email to register")
                //hide loader
                hud.dismiss()
                return
        }
        //Check if passwords match
        guard
            userPassword.text == userConfirmPassword.text
            else{
                SCLAlertView().showWarning("Passwords don't match", subTitle: "You need to type the same password twice")
                //hide loader
                hud.dismiss()
                return
        }
        //Control the password is at least 6 characters
        guard
            let passwordLongEnough = userPassword.text,
            passwordLongEnough.count > 0
            else {
                SCLAlertView().showWarning("Invalid entry", subTitle: "Password has to be longer than 6 characters")
                //hide loader
                hud.dismiss()
                return
        }
        
        
        //Connect to OWN server
        switch client!.connect(timeout: 10) {
        case .success:
            print("Connected to host")
        case .failure(let error):
            print("conectar a OWN server en Register ha fallado")
            print(String(describing: error))
        }
        //notify registration OWN servers
        let registerRequest = UserNote()
        registerRequest.buildNote("REGISTER", userMail.text!, "", "", "")
        let json = registerRequest.getJson()
        let dataToSend = "\(json)"
        let response = self.sendJson(self, dataToSend)
        
        print("\n\n\nRESPONSE FROM SERVER AFTER REGSITER: ", response)
        let jsonData = Data(response.utf8)
        let decoder = JSONDecoder()
        if(response != "[ERROR][sendJson]"){//Own Server did respond
            do {
                let ackJsonDecoded = try decoder.decode(ACKRegisterDecodedStruct.self, from: jsonData)
                if(ackJsonDecoded.opCode == "REGISTER" && ackJsonDecoded.result == "ACK"){
                    //---Server added user to OWN database
                    //-------Then add to Firebase Database
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
                            Auth.auth().currentUser?.sendEmailVerification { (error) in
                                if error != nil { //ERROR
                                    SCLAlertView().showError("Email Verification", subTitle: "We could not send the verification email")
                                }else{//NO ERROR
                                    //Tell user to vericication email has been sent
                                    SCLAlertView().showInfo("Verification email  sent", subTitle: "Check your inbox to find the verification E-mail")
                                    //Show user that the registration has been completed
                                    SCLAlertView().showSuccess("Registration Success", subTitle: "You just need to verify your email to sign in")
                                    self.verifyEmailButton.isHidden = false
                                }
                            }
                            
                        }
                        guard (authResult?.user) != nil else { return }
                    }
                }else if(ackJsonDecoded.opCode == "REGISTER" && ackJsonDecoded.result == "ERROR"){
                    //--Server could not ACK adding user to OWN database
                    SCLAlertView().showError("Registration Error", subTitle: "Our Servers couldn't process your request, please try again in a few minutes.")
                }
            } catch {
                print(error.localizedDescription)
            }
        }else{//OWN server did not respond
            SCLAlertView().showError("Registration Error", subTitle: "Our Servers are unavailable at the moment, please try again in a few minutes.")
        }
        
        //clean up for future ocassions
        userMail.text = ""
        userPassword.text = ""
        userConfirmPassword.text = ""
        //hide loader
        hud.dismiss()
    }
    
    
    @IBAction func verifyEmailTouched(_ sender: Any) {
        self.sendVerificationEmail()
    }
    
    @objc private func sendVerificationEmail(){
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil { //ERROR
                SCLAlertView().showError("Email Verification", subTitle: "There has been an error sending the verification E-mail")
            }else{//NO ERROR
                //Verification email sent successfully
                SCLAlertView().showInfo("Verification email  sent", subTitle: "Check your inbox to find the verification E-mail")
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
