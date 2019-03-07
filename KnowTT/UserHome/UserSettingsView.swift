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
import SCLAlertView

class UserSettingsView: UIViewController {
    
    
    @IBOutlet weak var logOutButton: UIButton!
    //Essence of client
    var client: TCPClient?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        logOutButton.layer.cornerRadius = 15
    }
    
     @IBAction func logOutTapped(_ sender: Any) {
        #warning ("Implement disconnect form Server")
        /*To log out from own servers we perform two steps:
         1.Disconnect -> mark user as disconnected
         2.Exit --> close connection
         */
        do{
            let disconnectRequest = UserNote()
            disconnectRequest.buildNote("DISCONNECT", Auth.auth().currentUser!.email!, "", "", "")
            let json = disconnectRequest.getJson()
            let dataToSend = "\(json)"
            print("\t[USER SETTINGS VIEW] Disconnecting from server")
            let response = self.sendJson(self, dataToSend)
            print("\t[USER SETTINGS VIEW] Disconnect Response from server: \(response)")
            let jsonData = Data(response.utf8)
            let decoder = JSONDecoder()
            let ackJsonDecoded = try decoder.decode(ACKRegisterDecodedStruct.self, from: jsonData)
            if(ackJsonDecoded.opCode == "DISCONNECT" && ackJsonDecoded.result == "ACK"){
                //server notified of disconnect in successfull
                print("\t[USER SETTINGS VIEW] own server  processed the disconnect petition successfully")
                //Disconnect OK -> EXIT(close connection)
                do{
                    let exitRequest = UserNote()
                    exitRequest.buildNote("EXIT", Auth.auth().currentUser!.email!, "", "", "")
                    let json = exitRequest.getJson()
                    let dataToSend = "\(json)"
                    print("\t[USER SETTINGS VIEW] Setting user disconnected in OWN server")
                    let response = self.sendJson(self, dataToSend)
                    print("\t[USER SETTINGS VIEW] Exit Response from server: \(response)")
                    let jsonData = Data(response.utf8)
                    let decoder = JSONDecoder()
                    let ackJsonDecoded = try decoder.decode(ACKRegisterDecodedStruct.self, from: jsonData)
                    if(ackJsonDecoded.opCode == "EXIT" && ackJsonDecoded.result == "ACK"){
                        //Connection successfully closed with server
                        print("\t[USER SETTINGS VIEW] Closing connection with OWN server")
                        //DISCONNECTED -> CLOSED -> LOG OUT FROM FIREBASE
                        try! Auth.auth().signOut()
                    }
                    else if(ackJsonDecoded.opCode == "EXIT" && ackJsonDecoded.result == "ERROR"){
                        //Error closing connection with server
                        SCLAlertView().showError("Log out failed", subTitle: "You can't log out right now, please try again in a few minutes")
                        print("\t[USER SETTINGS VIEW] Closing connection with OWN server failed")
                        return
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }else if(ackJsonDecoded.opCode == "DISCONNECT" && ackJsonDecoded.result == "ERROR"){
                //server couldnt process disconnect petition
                SCLAlertView().showError("Log out failed", subTitle: "You can't log out right now, please try again in a few minutes")
                print("\t[LOGIN REGISTER VIEW] own server couldnt process set user disconnected petition")
                return
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // Logout from Firebase
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "startView")
            self.present(vc, animated: false, completion: nil)
        }
     }
    
    //Disconnect Socket Client
    
    //NETWORKING FUNCTIONS
    func sendJson(_ sender: Any, _ jsonString: String) -> String{
        
        if let response = sendData(string: jsonString, using: client!){
            return response
        }
        return "[ERROR][sendJson]"
    }
    
    //uses readResponse
    private func sendData(string: String, using client: TCPClient) -> String? {
        print("Iphone Sending Data . . .")
        switch client.send(string: string) {
        case .success:
            print("The data has been succesfully sent")
            return readResponse(from: client) //This is returning the string read from server
        case .failure(let error):
            print(String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10, timeout: 10) else {return nil}
        return String(bytes: response, encoding: .ascii)
    }
}
