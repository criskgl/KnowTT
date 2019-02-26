//
//  feedView.swift
//  KnowTT
//
//  Created by CK on 26/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit

class UserFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var myNoteList = ["Hi, this is a racoon", "Hi this is another racoon", "Hi this is a boring racoon", "Rami is a racoon","Cris is also a racoon", "IV is full of racoooooooooooooooooooooooooooooooooooooooooons" ]
    
    var selectedNote = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myNoteList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = myNoteList[indexPath.row]//Moving down array displaying our List
        return cell
    }
    
    //This function works when user selects a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = myNoteList[indexPath.row]
        performSegue(withIdentifier: "goToNoteDetailedView", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //get the destination controller and cast it to your detail class
        let detailedNoteController  = segue.destination as!  NoteDetailedView
        detailedNoteController.noteContent = selectedNote
    }
    
    
    //Function is called each time user edits tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            myNoteList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
