//
//  WPTextField.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/24.
//

import UIKit

public extension WPTextField{
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
    public var keyWords : [String] = []{
        didSet{
            createKeyWordkeys()
        }
    }
    
    /// 输入模式
    public var mode : WPTextField.InputMode
    
    /// 最大输入字符数
    public var maxCount = Int.max

    /// 私有api 关键字的key
    fileprivate var keyWordKeys : [String:String] = [:]
    
    /// 初始化一个输入框
    /// - Parameters:
    ///   - inputMode: 输入模式
    ///   - keywords: 关键字
    public init(inputMode:InputMode,_ keywords:[String]=[]) {
        self.mode = inputMode
        super.init(frame: .zero)
        self.keyWords = keywords
        delegate = self
        createKeyWordkeys()
        NotificationCenter.default.addObserver(self, selector: #selector(textFiledEditChanged), name:UITextField.textDidChangeNotification , object: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 创建关键字key
    private func createKeyWordkeys(){
        keyWordKeys.removeAll()
        keyWords.forEach { elmt in
            keyWordKeys[elmt] = ""
        }
    }
    
}

extension WPTextField:UITextFieldDelegate{
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if keyWords.count != 0 {
            let res = keyWordKeys[string]
            if mode == .filter {
                if res != nil {
                    return false
                }else{
                    return true
                }
            }else{
                if string == ""{ // 删除键
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

    @objc private func textFiledEditChanged(notifcation:Notification){
        
        // /获取高亮部分
         let selectedRange = markedTextRange
         let pos = position(from: beginningOfDocument, offset: 0)
         
         /// 如果在变化中是高亮部分在变，就不要计算字符了
         if (selectedRange != nil) && (pos != nil) {
             return
         }
        if text?.count ?? 0 >= maxCount {
            if let text = self.text{
                self.text = String(text.prefix(maxCount))
            }
         }
    }
}
