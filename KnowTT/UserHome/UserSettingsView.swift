//
//  UserSettingsView.swift
//  KnowTT
//
//  Created by CK on 27/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftSocket
class UserSettingsView: UIViewController {
    
    
    @IBOutlet weak var logOutButton: UIButton!
    //Essence of client
    var client: TCPClient?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        logOutButton.layer.cornerRadius = 15
        //Invoking TCP client
        client = TCPClient(address: "142.93.204.52", port: 8080)
    }
    
     @IBAction func logOutTapped(_ sender: Any) {
        #warning ("Implement disconnect form Server")
        client?.close()
        // Logout from Firebase
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "startView")
            self.present(vc, animated: false, completion: nil)
        }
     }
    
    //Disconnect Socket Client

    
}
