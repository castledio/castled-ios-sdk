//
//  ContentView.swift
//  CastledDemoSwiftUI
//
//  Created by antony on 04/07/2024.
//

import Castled
import CastledInbox
import SwiftUI

struct ContentView: View {
    @State private var presentInboxView = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea() // Set background color

                VStack {
                    Spacer()

                    NavigationLink("Go to Detail View", value: NavigationDestination.detailView)
                        .buttonStyle(.borderedProminent)
                        .tint(.teal) // Ensure button text color is white
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: {
                        Castled.sharedInstance.setUserId("antony@castled.io")

                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    NavigationLink(destination: InboxViewRepresentable()
                        .edgesIgnoringSafeArea(.all)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .toolbarColorScheme(.light, for: .navigationBar)
//                        .toolbarBackground(Color.teal, for: .navigationBar)
//                        .toolbarBackground(.visible, for: .navigationBar)
                        .navigationBarBackButtonHidden(true))
                    {
                        Text("Navigate to Inbox")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .edgesIgnoringSafeArea(.bottom) // Adjust as needed
                    .padding(.horizontal)
                    Button(action: {
                        presentInboxView = true

                    }) {
                        Text("Present Inbox")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }

            .sheet(isPresented: $presentInboxView) {
                InboxViewRepresentable().edgesIgnoringSafeArea(.all)
            }

            .navigationTitle("Castled")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color.teal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .detailView:
                    SecondView()
                case .inboxView:
                    // NavigationLink for InboxView directly handled
                    EmptyView() // Just to satisfy the compiler, this case won't be used.
                }
            }
        }.onAppear(perform: {
            setUpInboxCallback()
        })
    }

    func setUpInboxCallback() {
        CastledInbox.sharedInstance.observeUnreadCountChanges(listener: { unreadCount in
            print("Inbox unread count is \(unreadCount)")
        })

        CastledInbox.sharedInstance.getInboxItems(completion: { _, result, _ in
            print("getInboxItems \(result?.count)")
        })

        //       Castled.sharedInstance.dismissInboxViewController()
    }
}

enum NavigationDestination: Hashable {
    case detailView
    case inboxView
}

#Preview {
    ContentView()
}
