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
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"
    
    //Set up socket manager
    
    //let manager = SocketManager(socketURL: URL(string: "http://localhost:5056")!, config: [.log(true), .compress])
    //var socket: SocketIOClient!
    
    @IBOutlet weak var userLoggedInText: UILabel!
    override func viewDidLoad() {
        //self.socket = manager.defaultSocket;
        userLoggedInText.text = "User: \(userMail ?? userDefault)"
        //socket.connect()

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
    }
    
    
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    
}
    
    

