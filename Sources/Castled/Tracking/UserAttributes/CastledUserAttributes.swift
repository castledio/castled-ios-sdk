//
//  CastledUserAttributes.swift
//  Castled
//
//  Created by antony on 06/02/2024.
//

import Foundation

@objc public class CastledUserAttributes: NSObject {
   
    var attributes = [String: Any]()

    let FIRST_NAME = "first_name"
    let LAST_NAME = "last_name"
    let EMAIL = "email"
    let NAME = "name"
    let DOB = "date_of_birth"
    let GENDER = "gender"
    let PHONE_NUMBER = "phone_number"
    let CITY = "city"
    let COUNTRY = "country"

    override public init() {}

    @objc public func setName(_ name: String?) {
        attributes[NAME] = name
    }

    @objc public func setFirstName(_ firstName: String?) {
        attributes[FIRST_NAME] = firstName
    }

    @objc public func setLastName(_ lastName: String?) {
        attributes[LAST_NAME] = lastName
    }

    @objc public func setEmail(_ email: String?) {
        attributes[EMAIL] = email
    }

    @objc public func setDOB(_ dob: String?) {
        attributes[DOB] = dob
    }

    @objc public func setGender(_ gender: String?) {
        attributes[GENDER] = gender
    }

    @objc public func setPhone(_ phone: String?) {
        attributes[PHONE_NUMBER] = phone
    }

    @objc public func setCity(_ city: String?) {
        attributes[CITY] = city
    }

    @objc public func setCountry(_ country: String?) {
        attributes[COUNTRY] = country
    }

    @objc public func setCustomAttribute(_ key: String, _ value: Any?) {
        attributes[key] = value
    }

    @objc public func setAttributes(_ attrs: [String: Any]) {
        attributes.merge(attrs) { _, new in new }
    }

    func getAttributes() -> [String: Any] { attributes }
}
