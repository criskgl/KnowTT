//
//  NoteDetailedView.swift
//  KnowTT
//
//  Created by CK on 26/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit

class NoteDetailedView: UIViewController{
    
    @IBOutlet weak var detailedNoteTextContent: UITextView!
    @IBOutlet weak var dismissNoteButton: UIButton!
    
    
    var noteContent = String()
    override func viewDidLoad() {
        dismissNoteButton.layer.cornerRadius = 15
        detailedNoteTextContent.text = noteContent
        super.viewDidLoad()
    }

    @IBAction func dismissNoteTapped(_ sender: Any) {
        performSegue(withIdentifier: "backToFeed", sender: self)
    }
}
