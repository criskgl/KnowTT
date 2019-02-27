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
    
    var noteRefresher: UIRefreshControl!
    
    @IBOutlet weak var PullUpToRefreshTabTitle: UINavigationItem!
    @IBOutlet weak var noteTable: UITableView!
    
    
    @IBOutlet var tabBarIconFeed: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIconFeed.badgeValue = "\(myNoteList.count)"
        noteRefresher = UIRefreshControl()
        //noteRefresher.attributedTitle = NSAttributedString(string: "⬆️ Pull to refresh ⬆️")
        noteRefresher.addTarget(self , action: #selector(UserFeedViewController.populateTable), for: UIControl.Event.valueChanged)
        
        noteTable.addSubview(noteRefresher)
    }
    
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
            noteTable.reloadData()
        }
    }
    
    //This function handles
    @objc func populateTable (){
        PullUpToRefreshTabTitle.title = "Loading Knowts"
        for i in 1...100000
        {
            myNoteList.append("\(i)")
        }
        PullUpToRefreshTabTitle.title = "Pull Up to Refresh"
        noteTable.reloadData()
        noteRefresher.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = myNoteList[indexPath.row]
    }
    
}
