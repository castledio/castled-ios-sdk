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
        viewDismiss = dismissView
        viewDismiss.backgroundColor = .clear
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewDismiss.frame = bounds
    }

    private func setupViews() {
        backgroundColor = .clear
        DispatchQueue.main.async { [weak self] in
            if let closeImage = UIImage(named: "castled_close_icon_inverted", in: Bundle.resourceBundle(for: CastledDismissButton.self), compatibleWith: nil) {
                self?.imgClose.image = closeImage
            }
        }
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
