//
//  UserHomeViewController.swift
//  UCSellB
//
//  Created by CK on 17/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserHomeViewController: UIViewController{
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"
    @IBOutlet weak var welcomeUser: UILabel!
    override func viewDidLoad() {
        welcomeUser.text = "Welcome\(userMail ?? userDefault)"
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
    }
    
    

