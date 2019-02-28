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

class UserSettingsView: UIViewController {
    
    
    @IBOutlet weak var logOutButton: UIButton!
    override func viewDidLoad(){
        super.viewDidLoad()
        logOutButton.layer.cornerRadius = 15
    }
    
     @IBAction func logOutTapped(_ sender: Any) {
        #warning ("Implement disconnect form Server")
        // Logout from Firebase
        try! Auth.auth().signOut()
        
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "startView")
            self.present(vc, animated: false, completion: nil)
        }
     }
    
    //Disconnect Socket Client

    
}
