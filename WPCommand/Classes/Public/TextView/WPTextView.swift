//
//  WPTextView.swift
//  WPCommand
//
//  Created by WenPing on 2021/7/17.
//

import UIKit

open class WPTextView: UITextView {
    
    /// 过滤字符 只能单个字符过滤 例如[""]
    var filter : [String] = []{
        didSet{
            filterKeys.removeAll()
            oldValue.forEach { elmt in
                filterKeys[elmt] = ""
            }
        }
    }

    fileprivate var filterKeys : [String:String] = [:]

    /// 最大输入字符数
    var maxCount = Int.max

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension WPTextView:UITextViewDelegate{

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if filter.count != 0 {
            let res = filterKeys[text]
            if res != nil {
                return true
            }else{
                return false
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

    }

}
