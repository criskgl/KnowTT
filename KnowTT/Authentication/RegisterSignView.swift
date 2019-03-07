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
import SwiftSocket



class RegisterSignView: UIViewController {
    //Outlets
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var emailToVerify = ""
    var passToVerify = ""

    //Essence of client
    var client: TCPClient?
    
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
        //Invoking TCP client
        client = TCPClient(address: "142.93.204.52", port: 8080)
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
                print("\t[LOGIN REGISTER VIEW] Sign in to FIREBASE failed")
                return
            }else{
                //Firebase Sign in Success
                print("\t[LOGIN REGISTER VIEW] Sign in to FIREBASE success")
                //--Check if email has been verified
                guard //Take care of unverified users
                    Auth.auth().currentUser?.isEmailVerified == true
                    else {
                    //--If email not verified
                        print("\t[LOGIN REGISTER VIEW] Email not verified")
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
                        print("\t[LOGIN REGISTER VIEW] Sign out FIREBASE")
                        try! Auth.auth().signOut()
                    return
                }
                //--Email has been verified
                //-Request SIGN in in OWN server
                //Connect to OWN server
                hud.show(in: self.view)
                switch self.client!.connect(timeout: 10) {
                case .success:
                    print("\t[LOGIN REGISTER VIEW] Connected to host")
                case .failure(let error):
                    print("\t[LOGIN REGISTER VIEW] Could not connect to host")
                    print(String(describing: error))
                    SCLAlertView().showError("Error Signing in", subTitle: "Our servers are down at the moment, try again in a few minutes")
                    hud.dismiss()
                    //Sign out the user from firebase
                    try! Auth.auth().signOut()
                    return
                }
                
                do{
                    print("\t[LOGIN REGISTER VIEW] Sign out FIREBASE")
                    try! Auth.auth().signOut()
                    print("\t[LOGIN REGISTER VIEW] Performing Sign in")
                    let exitRequest = UserNote()
                    exitRequest.buildNote("CONNECT", self.userMail.text!, "", "", "")
                    let json = exitRequest.getJson()
                    let dataToSend = "\(json)"
                    let response = self.sendJson(self, dataToSend)
                    print("\t[LOGIN REGISTER VIEW] Response from server: \(response)")
                    let jsonData = Data(response.utf8)
                    let decoder = JSONDecoder()
                    if(response != "[ERROR][sendJson]"){
                        //Own server did respond
                        let ackJsonDecoded = try decoder.decode(ACKRegisterDecodedStruct.self, from: jsonData)
                        if(ackJsonDecoded.opCode == "CONNECT" && ackJsonDecoded.result == "ACK"){
                            //server notified of sign in successfull
                            print("\t[LOGIN REGISTER VIEW] server sign in sucessfull in own servers")
                            
                            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                                if let error = error, user == nil {
                                    //Firebase Sign in Failed
                                    SCLAlertView().showError("Error Signing in", subTitle: error.localizedDescription)
                                    try! Auth.auth().signOut()
                                    hud.dismiss()
                                    return
                                }else{//Firebase Sign in Success
                                    print("\t[LOGIN REGISTER VIEW] server sign in sucessfull in firebase")
                                    //-Go to user home
                                    print("\t[LOGIN REGISTER VIEW] Going to user home...")
                                    self.performSegue(withIdentifier: "RegisterSignToUserHome", sender: self)
                                    hud.dismiss()
                                }
                            }
                            
                        }else if (ackJsonDecoded.opCode == "CONNECT" && ackJsonDecoded.result != "ACK"){
                            //OWN server notified of error signing in
                            print("\t[LOGIN REGISTER VIEW] server could not sign in")
                            SCLAlertView().showError("Error Signing in", subTitle: "Our servers are down at the moment, try again in a few minutes")
                            hud.dismiss()
                            return 
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        hud.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //get the destination controller and cast it to your detail class
        if(segue.identifier == "RegisterSignToUserHome"){
            let userHomeController  = segue.destination as?  UserHomeViewController
            userHomeController?.client = self.client
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

