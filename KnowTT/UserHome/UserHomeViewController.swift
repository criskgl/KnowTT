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

struct Annotation{
    var opCode: String
    var userId: String
    var latitude: String
    var longitude: String
    var note: String
}

class UserHomeViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var tcpLog: UITextField!
    @IBOutlet weak var userLoggedInText: UILabel!
    @IBOutlet weak var userMap: MKMapView!
    
    //LOCATION MANAGER
    let coordinatesManager = CLLocationManager()
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"
    //Essence of client
    var client: TCPClient?
    
    override func viewDidLoad() {
        //Ask user to start tracking his position
        self.coordinatesManager.requestAlwaysAuthorization()
        //if the user allows, set the delegate to the same coordinatesManager
        if CLLocationManager.locationServicesEnabled(){
            coordinatesManager.delegate = self
            coordinatesManager.desiredAccuracy = kCLLocationAccuracyBest
            coordinatesManager.startUpdatingLocation()
        }
        userLoggedInText.text = "Welcome \(userMail ?? userDefault) !"

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
            if let response = sendData(string:"Hey there, Im the Iphone!", using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
    
    func sendJson(_ sender: Any, _ jsonString: String) {
        //Trying to send messages
        guard let client = client else{return}
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host")
            if let response = sendData(string: jsonString, using: client){
                appendToTextField(string: "Response: \(response)")
            }
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
    }
    
    @IBAction func addNoteTouched(_ sender: Any) {
        //Set opcode
        let opCode = "1"
        //Get userId
        let userId = "\(userMail!))"
        //Get locations from user
        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)
        let userLatitudeCoord = coordinate.latitude
        let userLongitudeCoord = coordinate.longitude
        let userLongitude = "\(userLongitudeCoord)"
        let userLatitude = "\(userLatitudeCoord)"
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New KnowT", message: "Latitude: \(userLatitude)\nLongitude: \(userLongitude)", preferredStyle: .alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Your note goes here"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        // 3. Grab the value from the text field, and SEND IT TO SERVER
        alert.addAction(UIAlertAction(title: "KnowtIt", style: .default, handler:
            {
                [weak alert] (_) in
                let userNoteRaw = alert?.textFields![0] // This is the user note
                let userNote = userNoteRaw?.text!
                let note = UserNote()
                note.buildNote(opCode, userId, userLatitude, userLongitude, userNote!)
                let json = note.getJson()
                let dataToSend = "\(json)"
                self.sendJson(self, dataToSend)
            }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    private func sendData(string: String, using client: TCPClient) -> String? {
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
    
    //Track the user position in real time and display it on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let userPosition:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(userPosition.latitude) \(userPosition.longitude)")
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 100, longitudinalMeters: 100)
        self.userMap.setRegion(viewRegion, animated: true)
        self.userMap.showsUserLocation = true
        
        //Save current lat & long
        UserDefaults.standard.set(userLocation?.coordinate.latitude, forKey: "LAT")
        UserDefaults.standard.set(userLocation?.coordinate.longitude, forKey: "LON")
        UserDefaults().synchronize()
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
