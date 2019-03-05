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

class ForgotPassword: UIViewController {
    @IBOutlet weak var emailUser: UITextField!
    @IBOutlet weak var sendEmailButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    sendEmailButton.layer.cornerRadius = 15
    }
    @IBAction func sendResetEmailTouched(_ sender: Any) {
        guard
            
    Auth.auth().sendPasswordReset(withEmail: emailUser.text!) { error in
            // ...
        }
    }
}
