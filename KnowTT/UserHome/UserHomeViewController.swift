//
//  UserHomeViewController.swift
//  KnowTT
//
//  Created by CK on 17/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SocketIO
import SwiftSocket

class UserHomeViewController: UIViewController{

    @IBOutlet weak var tcpLog: UITextField!
    @IBOutlet weak var userLoggedInText: UILabel!
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"
    //Essence of client
    var client: TCPClient?
    
    override func viewDidLoad() {
        userLoggedInText.text = "User: \(userMail ?? userDefault)"

        //Invoking TCP client
        client = TCPClient(address: "142.93.204.52", port: 8080)
        super.viewDidLoad()
    }
    @IBAction func logOutTapped(_ sender: Any) {
        // 1
            try! Auth.auth().signOut()
        
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "startView")
                
                self.present(vc, animated: false, completion: nil)
            }
        }
    
    @IBAction func connectTapped(_ sender: Any) {
        //Trying to send messages
        guard let client = client else{return}
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host")
            if let response = sendRequest(string:"Hey there, Im the Iphone!", using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Iphone Sending Data . . .")
        
        switch client.send(string: string) {
        case .success:
            appendToTextField(string: "The data has been succesfully sent")
            return readResponse(from: client) //This is returning the string read from server
        case .failure(let error):
            print("error sending data from Iphone")
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else {return nil}
        print("SERVER RESPONSE: \(response)")
        return String(bytes: response, encoding: .utf8)
    }
    
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func appendToTextField(string: String){
        print(string)
        tcpLog.text = tcpLog.text?.appending("\n\(string)")
    }

    
    
}

/*
//TCPswiftSocket------Down
let client = TCPClient(address: "142.93.204.52", port: 8080)
switch client.connect(timeout: 1) {
case .success:
    print("IOs App succesfully connected to Server")
    switch client.send(string: "Goooooooteeeeeemmmmm" ) {
    case .success:
        guard let data = client.read(1024*10) else
        {
            return
        }
        
        if let response = String(bytes: data, encoding: .utf8) {
            print(response)
        }
    case .failure(let error):
        print(error)
    }
case .failure(let error):
    print(error)
}

//TCPswiftSocket------Finished
    
*/
