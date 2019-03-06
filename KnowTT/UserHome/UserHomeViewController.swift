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
import MapKit
import SCLAlertView

struct PostNoteDecodedStruct: Codable {
    var latitude: String
    var longitude: String
    var message: String
    var userId: String
}

struct ACKPostNoteDecodedStruct: Codable {
    var opCode: String
    var result: String
}

class UserHomeViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var tcpLog: UITextField!//This is for testing
    @IBOutlet weak var userLoggedInText: UILabel!
    @IBOutlet weak var userMap: MKMapView!
    
    //LOCATION MANAGER
    let coordinatesManager = CLLocationManager()
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"
    //Essence of client
    var client: TCPClient?
    //Timer to call datbase every X seconds to retrieve nearby notes
    var myTimer = Timer()
    
    
    //Prepare to change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style:UIStatusBarStyle = .default
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       self.style = .lightContent
    }
    override func viewDidLoad() {
        #warning ("used for testing purposes")
        if(Auth.auth().currentUser?.email == nil){
            print("Firebase Debug: No user connected")
        }else{
            print("Firebase Debug: user \(Auth.auth().currentUser!.email!) is connected")
        }
        /********************/
        //Start the method were we request nearby notes to the server every X time
        #warning ("This to be built later TODO...")
        //scheduledTimerWithTimeInterval()
        /********************/
        //Change status bar color
        self.style = .lightContent
        //Ask user to start tracking his position
        self.coordinatesManager.requestAlwaysAuthorization()
        //if the user allows, set the delegate to the same coordinatesManager
        if CLLocationManager.locationServicesEnabled(){
            coordinatesManager.delegate = self
            coordinatesManager.desiredAccuracy = kCLLocationAccuracyBest
            coordinatesManager.startUpdatingLocation()
        }

        //Change welcome message based on user name/email
        userLoggedInText.text = "Welcome \(userMail ?? userDefault) !"
        //Invoking TCP client
        client = TCPClient(address: "142.93.204.52", port: 8080)
        super.viewDidLoad()
        //Connect to server
        guard let client = client else{return}
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host")
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        #warning ("Implement security handshake")
    
    }
    #warning ("this function is for testing")
    @IBAction func connectAndSend(_ sender: Any) {
        let response = sendData(string:"Hey there, Im the Iphone!", using: client!)
        appendToTextField(string: "Response: \(response!)")
        }

    #warning ("this function is for testing")
    @IBAction func connectTapped(_ sender: Any) {
        //Trying to send messages
        guard let client = client else{return}
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host")
            if let response = sendData(string:"Hey there, Im the Iphone!", using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }

 
    
    @IBAction func addNoteTouched(_ sender: Any) {
        //Set opcode
        let opCode = "POST"
        //Get userId
        let userId = "\(userMail!)"
        //Get locations from user
        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)
        let userLatitudeCoord = coordinate.latitude
        let userLongitudeCoord = coordinate.longitude
        let userLongitude = "\(userLongitudeCoord)"
        let userLatitude = "\(userLatitudeCoord)"
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New KnowT", message: "Latitude: \(userLatitude)\nLongitude: \(userLongitude)", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "Your note goes here"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        // 3. Grab the value from the text field, and SEND IT TO SERVER
        alert.addAction(UIAlertAction(title: "Add Note", style: .default, handler:
            {
                [weak alert] (_) in
                let userNoteRaw = alert?.textFields![0] // This is the user note
                let userNote = userNoteRaw?.text!
                let note = UserNote()
                note.buildNote(opCode, userId, userLatitude, userLongitude, userNote!)
                let json = note.getJson()
                let dataToSend = "\(json)"
                let response = self.sendJson(self, dataToSend)
                //Once we have the response then put it into a struct
                let jsonData = Data(response.utf8)
                let decoder = JSONDecoder()
                do {
                    let ackJsonDecoded = try decoder.decode(ACKPostNoteDecodedStruct.self, from: jsonData)
                    if(ackJsonDecoded.opCode == "POST" && ackJsonDecoded.result == "ACK"){
                        
                        let latitudeEffectiveValue = (userLatitude as NSString).doubleValue
                         let longitudeEffectiveValue = (userLongitude as NSString).doubleValue
                        self.pinNote(withText: userNote!, inLatitude: latitudeEffectiveValue, inLongitud: longitudeEffectiveValue)
                    }else{
                        SCLAlertView().showError("Could not post your note", subTitle: "Please try again in a few minutes")
                    }
                } catch {
                    print(error.localizedDescription)
                }
                print(response)
            }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    //uses sendData
    func sendJson(_ sender: Any, _ jsonString: String) -> String{
        
        if let response = sendData(string: jsonString, using: client!){
            print("Result from server: ", response)
            appendToTextField(string: "Response: \(response)")
            return response
        }
        return "[ERROR][sendJson]"
    }
    //uses readResponse
    private func sendData(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Iphone Sending Data . . .")
        switch client.send(string: string) {
        case .success:
            appendToTextField(string: "The data has been succesfully sent")
            return readResponse(from: client) //This is returning the string read from server
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10, timeout: 10) else {return nil}
        return String(bytes: response, encoding: .ascii)
    }
    func createAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func pinNote(withText note:String,  inLatitude latitude: Double, inLongitud longitude: Double){
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = userMail
        annotation.subtitle = note
        userMap.addAnnotation(annotation)
    }
    #warning ("This Function is for testing")
    private func appendToTextField(string: String){
        tcpLog.text = tcpLog.text?.appending("\n\(string)")
    }
    //Track the user position in real time and display it on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update User Location
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 100, longitudinalMeters: 100)
        self.userMap.setRegion(viewRegion, animated: true)
        self.userMap.showsUserLocation = true
        
        
        //Save current lat & long
        UserDefaults.standard.set(userLocation?.coordinate.latitude, forKey: "LAT")
        UserDefaults.standard.set(userLocation?.coordinate.longitude, forKey: "LON")
        UserDefaults().synchronize()
    
    }
    func scheduledTimerWithTimeInterval(){
              print("[SCHEDULED TIMER WITH INTERVAL]")
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        myTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(UserHomeViewController.updateCloseByNotes), userInfo: nil, repeats: true)
    }
    @objc func updateCloseByNotes(){
        print("[UPDATE CLOSE BY NOTES]")
        let number = Int.random(in: 0 ..< 100)
        appendToTextField(string: "\(number)")
        
        //Request notes when user is moving
        //Get userId
        let userId = "\(userMail!)"
        
        //MARK-- Reload Notes when user is moving
        let noteRequest = UserNote()
        //Get location data
        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)//Get last location saved.
        let userLatitudeCoord = coordinate.latitude
        let userLongitudeCoord = coordinate.longitude
        let userLongitude = "\(userLongitudeCoord)"
        let userLatitude = "\(userLatitudeCoord)"
        //1.Build  the note
        noteRequest.buildNote("GET", userId, userLatitude, userLongitude, "")
        //2.Get the json
        let jsonRequest = noteRequest.getJson()
        //3.Convert json to secure String being sent
        let dataToSend = "\(jsonRequest)"
        print(dataToSend)
        //4.Send the request and recieve first response
        var response = self.sendJson(self, dataToSend)
        #warning ("This folowing line is for testing")
        appendToTextField(string: response)
        var moreNotes = self.pinNoteAndCheckForMore(fromStringJson: response)
        while(moreNotes == true){
            response = self.sendJson(self, dataToSend)
            print("THIS IS THE RESPONSEEEE: \(response)")
            moreNotes = pinNoteAndCheckForMore(fromStringJson: response)
        }
    }
    
    func pinNoteAndCheckForMore(fromStringJson json: String) -> Bool{
        //put json in required format for decoder
        let jsonData = Data(json.utf8)
        //create decoder
        let decoder = JSONDecoder()
        var moreNotes = true
        do {
            //Initialize Struct to save data
            let ackJsonDecoded = try decoder.decode(PostNoteDecodedStruct.self, from: jsonData)
            //Check if we have final end marking note
            if(ackJsonDecoded.message == "[END]"){
                moreNotes = false
            }else{//If there are more notes...
                //Get location from note
                let latitudeEffectiveValue = (ackJsonDecoded.latitude as NSString).doubleValue
                let longitudeEffectiveValue = (ackJsonDecoded.longitude as NSString).doubleValue
                
                self.pinNote(withText: ackJsonDecoded.message, inLatitude: latitudeEffectiveValue, inLongitud: longitudeEffectiveValue)
            }
        }catch {
            print(error.localizedDescription)
            moreNotes = false
            return moreNotes
        }
        return moreNotes
    }
    
 
}



