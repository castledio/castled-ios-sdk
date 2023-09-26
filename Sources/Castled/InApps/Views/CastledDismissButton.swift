//
//  CastledDismissButton.swift
//  CastledInAppHTMLPOC
//
//  Created by antony on 04/08/2023.
//

import UIKit

struct DismissViewActions {
    let dismissBtnClickedAction: (_ sender: Any) -> Void

}

class CastledDismissButton: UIView {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    private weak var viewDismiss: UIView!
    private var actions: DismissViewActions?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        let dismissView = UINib.loadView(String(describing: Self.self), owner: self)
        addSubview(dismissView)
        self.viewDismiss = dismissView
        self.viewDismiss.backgroundColor = .clear
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewDismiss.frame = bounds
    }

    private func setupViews() {
        self.backgroundColor = .clear
        let closeImage = imgClose.image?.withRenderingMode(.alwaysTemplate)
        imgClose.image = closeImage
        imgClose.tintColor = .white
        imgClose.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        imgClose.layer.cornerRadius = imgClose.frame.size.height/2
        imgClose.addShadow(radius: 5, opacity: 0.6, offset: CGSize(width: 0, height: 2), color: UIColor.black)

    }

    func initialiseActions(actions: DismissViewActions? = nil) {
        self.actions = actions
    }

    @IBAction func dismissBtnClicked(_ sender: Any) {
        actions?.dismissBtnClickedAction(sender)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

}
extension UINib {
    static func loadView<T>(_ nibName: String, owner: T) -> UIView {

        let nib = UINib(nibName: nibName, bundle: Bundle.resourceBundle(for: CastledDismissButton.self))
        return nib.instantiate(withOwner: owner, options: nil)[0] as! UIView
    }
}
