//
//  SecondView.swift
//  CastledDemoSwiftUI
//
//  Created by antony on 04/07/2024.
//

import Castled
import SwiftUI

struct SecondView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("This is the SecondView")
                    .foregroundColor(.teal)
                Spacer()
                Button(action: {
                    logEventtracking()
                }) {
                    Text("Event Tracking")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Button(action: {
                    logUserAttributes()
                }) {
                    Text("Set User Attributes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Detail")
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbarBackground(Color.teal, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

func logEventtracking() {
    Castled.sharedInstance.logCustomAppEvent("added_to_cart", params: ["Int": 100, "Date": "12-16-2000", "Name": "Antony"])
}

func logUserAttributes() {
    let userAttributes = CastledUserAttributes()
    userAttributes.setFirstName("Antony Joe Mathew 1")
    userAttributes.setLastName("Mathew")
    userAttributes.setCity("Sanfrancisco")
    userAttributes.setCountry("US")
    userAttributes.setEmail("doe@email.com")
    userAttributes.setDOB("02-01-1995")
    userAttributes.setGender("M")
    userAttributes.setPhone("+13156227533")
    // Custom Attributes
    userAttributes.setCustomAttribute("prime_member", true)
    userAttributes.setCustomAttribute("int", 500)
    userAttributes.setCustomAttribute("double", 500.01)
    userAttributes.setCustomAttribute("occupation", "artist")
    Castled.sharedInstance.setUserAttributes(userAttributes)
}

#Preview {
    SecondView()
}
