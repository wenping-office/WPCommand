//
//  WPTextField.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

public extension WPTextField {
    /// 输入模式
    enum InputMode {
        /// 过滤模式 默认过滤当前的关键字
        case filter
        /// 输入模式 只能输入当前的关键字
        case input
    }
}

open class WPTextField: UITextField {
    /// 过滤字符 只能单个字符过滤 例如[""]
    public var keyWords: [String] = [] {
        didSet {
            createKeyWordkeys()
        }
    }
    
    /// 内容变动监听
    public var textChange: ((WPTextField) -> Void)? {
        didSet {
            textChange?(self)
        }
    }

    /// 输入模式
    public var mode: WPTextField.InputMode
    /// 最大输入字符数
    public var maxCount = Int.max
    /// 过滤高亮后的text
    public var filterText: String? {
        if let textRange = markedTextRange {
            if textRange.isEmpty {
                return text
            } else {
                let highStrCount = text(in: textRange)?.count ?? 0
                let maxCount = text?.count ?? 0
                return text?.wp.first(of: maxCount - highStrCount)
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
    
    override open var text: String? {
        didSet {
            textChange?(self)
        }
    }

    /// 初始化一个输入框
    /// - Parameters:
    ///   - inputMode: 输入模式
    ///   - keywords: 关键字
    public init(inputMode: InputMode, _ keywords: [String] = []) {
        self.mode = inputMode
        super.init(frame: .zero)
        self.keyWords = keywords
        delegate = self
        createKeyWordkeys()
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledEditChanged), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension WPTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if keyWords.count != 0 {
            let res = keyWordKeys[string]
            if mode == .filter {
                if res != nil {
                    return false
                } else {
                    return true
                }
            } else {
                if string == "" { // 删除键
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

    @objc private func textFiledEditChanged(notifcation: Notification) {
        // /获取高亮部分
        let selectedRange = markedTextRange
        let pos = position(from: beginningOfDocument, offset: 0)
         
        /// 如果在变化中是高亮部分在变，就不要计算字符了
        if selectedRange != nil, pos != nil {
            textChange?(self)
            return
        }
        if text?.count ?? 0 >= maxCount {
            if let text = self.text {
                self.text = String(text.prefix(maxCount))
            }
        }
        
        textChange?(self)
    }
}
