//
//  Validations.swift
//  ContactRegister
//
//  Created by Alan Briceño on 21/08/18.
//  Copyright © 2018 Alan Briceño. All rights reserved.
//

import Foundation

let format = "SELF MATCHES[c] %@"

func isValidEmail(_ email: String) -> Bool {
    let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

    let emailTest = NSPredicate(format: format, regEx)
    return emailTest.evaluate(with: email)
}

func isValidString(_ str: String) -> Bool {
    let regEx = "^[A-Z]+[a-zA-Z]*$"
    
    let stringTest = NSPredicate(format: format, regEx)
    return stringTest.evaluate(with: str)
}

func isValidNumber(_ number: String) -> Bool {
    let regEx = "[0-9]{0,14}"
    
    let numberTest = NSPredicate(format: format, regEx)
    return numberTest.evaluate(with: number)
}
    



