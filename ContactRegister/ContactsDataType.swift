//
//  ContactsDataType.swift
//  ContactRegister
//
//  Created by Alan Briceño on 20/08/18.
//  Copyright © 2018 Alan Briceño. All rights reserved.
//

struct ContactsResult: Codable {
    var Contacts: [Contact]
    var Location: Location
    var RegisteredBy: RegisteredBy
    var `Type`: Int = 1
}

struct Contact: Codable {
    var Company: String
    var EmailsAddress: [String]
    var LastName: String
    var Name: String
    var PhoneNumbers: [PhoneNumbers]
    var Photo: String
}

struct PhoneNumbers: Codable {
    var Country: Country
    var Number: String
}

struct Country: Codable {
    var Code: Int
    var Name: String
}

struct Location: Codable {
    var Latitude: Int = 15
    var Longitude: Int = 15
}

struct RegisteredBy: Codable {
    var Name: String = "Alan Alexis Briceño Brito"
}


