//
//  User.swift
//  driver_api
//
//  Created by WY on 2021/6/4.
//
import CoreLocation

enum AccountType: Int{
    case passenger
    case driver
}

struct User {
    let name: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    
    init(uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
