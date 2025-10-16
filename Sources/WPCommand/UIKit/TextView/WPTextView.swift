//
//  WPTextView.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/17.
//

import UIKit

public extension WPTextView {
    /// 输入模式
    enum InputMode {
        /// 过滤模式 过滤当前的关键字
        case filter
        /// 输入模式 只能输入当前的关键字
        case input
    }
}

open class WPTextView: UITextView {
    /// 过滤字符 只能单个字符过滤 例如[""]
    public var keyWords: [String] = [] {
        didSet {
            createKeyWordkeys()
        }
    }

    /// 内容改变
    public var textChange: ((WPTextView) -> Void)? {
        didSet {
            textChange?(self)
        }
    }

    /// 输入模式
    public var mode: WPTextView.InputMode
    /// 最大输入字符数
    public var maxCount = Int.max
    /// 过滤高亮后的text
    public var filterText: String! {
        if let textRange = markedTextRange {
            if textRange.isEmpty {
                return text
            } else {
                let highStrCount = text(in: textRange)?.count ?? 0
                return text.wp[safe: 0..<text.count - highStrCount]
            }
        } else {
            return text
        }
    }

    /// 是否禁用全选功能
    public var isSelectAllEnabled: Bool = false
    /// 是否禁用选中功能
    public var isSelectEnabled: Bool = false
    /// 是否禁用粘贴功能
    public var isPasteEnabled: Bool = false
    /// 是否禁用复制功能
    public var isCopyEnabled: Bool = false
    /// 是否禁用分享功能
    public var isShareEnabled: Bool = true
    /// 是否禁用删除功能
    public var isDeleteEnabled: Bool = false
    /// 私有api 关键字的key
    private var keyWordKeys: [String: String] = [:]

    override open var text: String! {
        didSet {
            textChange?(self)
        }
    }

    /// 初始化一个文本输入框
    /// - Parameters:
    ///   - inputMode: 输入模式
    ///   - keywords: 关键字
    public init(inputMode: InputMode, _ keywords: [String] = []) {
        self.mode = inputMode
        super.init(frame: .zero, textContainer: nil)
        self.keyWords = keywords
        delegate = self
        createKeyWordkeys()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建关键字key
    private func createKeyWordkeys() {
        keyWordKeys.removeAll()
        keyWords.forEach { elmt in
            keyWordKeys[elmt] = ""
        }
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let actionStr = action.description
        if actionStr == "selectAll:" {
            return isSelectAllEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else if actionStr == "copy:" {
            return isCopyEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else if actionStr == "paste:" {
            return isPasteEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else if actionStr == "select:" {
            return isSelectEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else if actionStr == "delete:" {
            return isDeleteEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else if actionStr == "_share:" {
            return isShareEnabled ? false : super.canPerformAction(action, withSender: sender)
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}

extension WPTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if keyWords.count != 0 {
            let res = keyWordKeys[text]
            if mode == .filter {
                if res != nil {
                    return false
                } else {
                    return true
                }
            } else {
                if text == "" { // 删除键
                    return true
                } else if res != nil {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return true
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // /获取高亮部分
        let selectedRange = textView.markedTextRange
        let pos = textView.position(from: textView.beginningOfDocument, offset: 0)
        
        /// 如果在变化中是高亮部分在变，就不要计算字符了
        if selectedRange != nil, pos != nil {
            textChange?(self)
            return
        }
        if textView.text.count >= maxCount {
            textView.text = String(textView.text.prefix(maxCount))
        }
        textChange?(self)
    }
}
