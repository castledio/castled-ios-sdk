//
//  InboxViewRepresentable.swift
//  CastledDemoSwiftUI
//
//  Created by antony on 05/07/2024.
//

import CastledInbox
import SwiftUI

struct InboxViewRepresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: CastledInboxViewController, context: Context) {}

    func makeUIViewController(context: Context) -> CastledInboxViewController {
        let style = CastledInboxDisplayConfig()
        style.inboxViewBackgroundColor = .white
        style.navigationBarBackgroundColor = .link
        style.navigationBarTitle = "Castled Inbox"
        style.navigationBarButtonTintColor = .white
        style.loaderTintColor = .blue
        let inboxVc = CastledInbox.sharedInstance.getInboxViewController(withUIConfigs: style, andDelegate: context.coordinator)
        return inboxVc
    }

    class Coordinator: NSObject, CastledInboxViewControllerDelegate {
        func didSelectedInboxWith(_ buttonAction: CastledButtonAction, inboxItem: CastledInboxItem) {
            print("didSelectedInboxWith type \(buttonAction.actionType) title '\(buttonAction.buttonTitle ?? "")' uri '\(buttonAction.actionUri ?? "")'kvPairs \(buttonAction.keyVals) inboxItem\(inboxItem)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

#Preview {
    InboxViewRepresentable()
}
