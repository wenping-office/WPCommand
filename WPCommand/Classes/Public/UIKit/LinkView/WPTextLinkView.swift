//
//  WPTextLinkView.swift
//  WPCommand
//
//  Created by Wen on 2023/10/16.
//

import UIKit

public class WPTextLinkView: WPBaseView {
    public var sizeLabel = UILabel()
    public var linkTextView = TextView()

    public var text: String? {
        set {
            sizeLabel.text = newValue
            linkTextView.text = newValue
            reset()
        }
        get {
            return sizeLabel.text
        }
    }

    public var textColor: UIColor = .black {
        didSet {
            reset()
        }
    }

    public var font: UIFont = .systemFont(ofSize: 16) {
        didSet {
            reset()
        }
    }

    public var lineSpacing: CGFloat = 5 {
        didSet {
            reset()
        }
    }

    public var linkColor = UIColor.blue {
        didSet {
            linkTextView.linkTextAttributes = [.foregroundColor: linkColor]
        }
    }

    var links: [(link: Link, domain: String)] = []

    public func add(link: Link) {
        let domani = "h\(String.wp.random(length: 10))://"
        links.append((link, domani))

        reset()
    }

    func reset() {
        var str = text?.wp.attributed

        for obj in links {
            str = str?.link(str: obj.domain, range: text?.wp.of(obj.link.key))
            str = str?.lineSpacing(lineSpacing)
            str = str?.font(font)
            str = str?.foregroundColor(textColor)
        }

        linkTextView.attributedText = str?.value()
        sizeLabel.attributedText = str?.value()
    }

    override public func initSubView() {
        super.initSubView()

        linkTextView.textContainerInset = .zero
        font = .systemFont(ofSize: 16)
        sizeLabel.numberOfLines = 0
        linkTextView.delegate = self
        linkTextView.isScrollEnabled = false
        linkTextView.backgroundColor = .clear
        sizeLabel.isHidden = true
        linkTextView.isEditable = false

        addSubview(sizeLabel)
        addSubview(linkTextView)

        sizeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        linkTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    override public func initSubViewLayout() {
        super.initSubViewLayout()

        sizeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        linkTextView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(5)
        }
    }
}

public extension WPTextLinkView {
    class TextView: UITextView {
        override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            let actionStr = action.description
            if actionStr == "selectAll:" {
                return false
            } else if actionStr == "copy:" {
                return false
            } else if actionStr == "paste:" {
                return false
            } else if actionStr == "select:" {
                return false
            } else if actionStr == "delete:" {
                return false
            } else if actionStr == "_share:" {
                return false
            } else {
                return false
            }
        }
    }
}
 
extension WPTextLinkView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let obj = links.wp_elmt { obj in
            obj.domain == URL.absoluteString
        }

        obj?.link.click?(URL.absoluteString)
        return true
    }
}

public extension WPTextLinkView {
    struct Link {
        let key: String
        let click: ((String) -> Void)?

        public init(key: String, click: ((String) -> Void)?) {
            self.key = key
            self.click = click
        }
    }
}
