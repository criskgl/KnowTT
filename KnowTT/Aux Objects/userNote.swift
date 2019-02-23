//
//  userNote.swift
//  KnowTT
//
//  Created by CK on 21/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation

class UserNote {
    var opCode: String?
    var userId: String?
    var latitude: String?
    var longitude: String?
    var note: String?
    
    func buildNote(_ opCode: String, _ userId: String, _ latitude: String, _ longitude: String, _ note: String){
        self.opCode = opCode
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.note = note
    }
    
    func getJson() -> Any{
        //Build dictionary
        let dictionary = ["opCode": self.opCode, "userId": self.userId, "longitude": self.longitude, "latitude": self.latitude, "message": self.note]
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            return theJSONText ?? ""
        }
        return "Error"
    }
}

/*
 private func getDictionary(withOpcode opCode: String, fromUserWithId userId: String, inLongitude longitude: String, inLatitude latitude: String, withNote note: String) -> [String: String]{
 let dic = ["opCode": opCode, "userId": userId, "longitude": longitude, "latitude": latitude, "note": note]
 return dic
 }
 */
