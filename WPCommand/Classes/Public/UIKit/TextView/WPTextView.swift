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
    public var keyWords : [String] = []{
        didSet{
            createKeyWordkeys()
        }
    }
    
    /// 内容改变
    public var textChange : ((WPTextView)->Void)?

    /// 输入模式
    public var mode : WPTextView.InputMode
    
    /// 最大输入字符数
    public var maxCount = Int.max
    
    /// 私有api 关键字的key
    fileprivate var keyWordKeys : [String:String] = [:]

    open override var text: String!{
        didSet{
            textChange?(self)
        }
    }

    /// 初始化一个文本输入框
    /// - Parameters:
    ///   - inputMode: 输入模式
    ///   - keywords: 关键字
    public init(inputMode:InputMode,_ keywords:[String]=[]) {
        self.mode = inputMode
        super.init(frame: .zero, textContainer: nil)
        self.keyWords = keywords
        delegate = self
        createKeyWordkeys()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建关键字key
    private func createKeyWordkeys(){
        keyWordKeys.removeAll()
        keyWords.forEach { elmt in
            keyWordKeys[elmt] = ""
        }
    }
    
}

extension WPTextView:UITextViewDelegate{
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if keyWords.count != 0 {
            let res = keyWordKeys[text]
            if mode == .filter {
                if res != nil {
                    return false
                }else{
                    return true
                }
            }else{
                if text == ""{ // 删除键
                    return true
                }else if res != nil {
                    return true
                }else{
                    return false
                }
            }
        }else{
            return true
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // /获取高亮部分
        let selectedRange = textView.markedTextRange
        let pos = textView.position(from: textView.beginningOfDocument, offset: 0)
        
        /// 如果在变化中是高亮部分在变，就不要计算字符了
        if (selectedRange != nil) && (pos != nil) {
            return
        }
        if textView.text.count >= maxCount {
            textView.text = String(textView.text.prefix(maxCount))
        }
        
        textChange?(self)
    }
    
}
