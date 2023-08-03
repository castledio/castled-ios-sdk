//
//  CIViewProtocol.swift
//  Castled-iOS-SDK
//
//  Created by antony on 03/08/2023.
//

import Foundation
import UIKit

protocol CIViewProtocol  {

    var parentContainerVC : CastledInAppDisplayViewController? {get set}
    var viewContainer : UIView? { get set }
    var selectedInAppObject : CastledInAppObject? {get set}
    var inAppDisplaySettings : InAppDisplayConfig? {get set}
    var mainImage : UIImage? { get set }
    func configureTheViews()
    func addTheInappViewInContainer(inappView view :UIView)
}
extension CIViewProtocol{

    func addTheInappViewInContainer(inappView view :UIView){
        guard let contianer = viewContainer else{
            return
        }
        contianer.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contianer.topAnchor),
            view.leadingAnchor.constraint(equalTo: contianer.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contianer.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contianer.trailingAnchor)
        ])

        configureTheViews()
    }
}
