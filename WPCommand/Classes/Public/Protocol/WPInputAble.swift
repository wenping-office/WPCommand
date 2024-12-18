//
//  WPInputAble.swift
//  WPCommand
//
//  Created by Wen on 2024/1/16.
//

import UIKit
import RxCocoa
import RxSwift

private var wp_inputNumberdisposeBagPointer = "wp_inputNumberdisposeBagPointer"

/// 输入协议
public protocol WPInputAble:NSObject{}
extension UITextField:WPInputAble{}
extension UITextView:WPInputAble{}

extension WPInputAble{
    func rxText() -> ControlProperty<String?>{
        if self is UITextField{
            return (self as! UITextField).rx.text
        } else if self is UITextView{
            return (self as! UITextView).rx.text
        }
        return UITextView().rx.text
    }
    
    func inputComplete() -> Observable<String?>{
        if self is UITextField{
            return (self as! UITextField).rx.controlEvent(.editingDidEnd).map {[weak self] _ in
                return (self as! UITextField).text
            }
        } else if self is UITextView{
            return (self as! UITextView).rx.didEndEditing.map { [weak self] _ in
                return (self as! UITextView).text
            }
        }
        return .just(nil)
    }
    
    func markedTextRange() -> UITextRange?{
        if self is UITextField{
            return (self as! UITextField).markedTextRange
        } else if self is UITextView{
            return (self as! UITextView).markedTextRange
        }
        return nil
    }
}

extension WPInputAble{
    /// 懒加载垃圾袋
    var wp_inputNumberDisposeBag: DisposeBag {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &wp_inputNumberdisposeBagPointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let disposeBag: DisposeBag = WPRunTime.get(self, withUnsafePointer(to: &wp_inputNumberdisposeBagPointer, {$0})) else {
                let bag = DisposeBag()
                self.wp_inputNumberDisposeBag = bag
                return bag
            }
            return disposeBag
        }
    }
}

public extension WPSpace where Base: WPInputAble {
    
    /// 最大字符输入限制
    /// - Parameters:
    ///   - count: 长度
    ///   - mode: 输入模式
    /// - Returns: 语法糖
    @discardableResult
    func maxCount(_ count:Int,
                  _ mode:InputMode = .filter()) -> Self {
        base.wp_inputNumberDisposeBag = DisposeBag()
        
        base.rxText().map({ str in
            var newStr = str
            switch mode {
            case .input(let keys):
               var newValue:String = ""
                var newRes = str?.wp.checkingResult(keys)
                newRes?.sort(by: { v1, v2 in
                    return v1.range.location < v2.range.length
                })
                newRes?.forEach({ resualt in
                    newValue += (str as? NSString)?.substring(with: resualt.range) ?? ""
                })
                newStr = newValue
            case .filter(let keys):
                if keys.count > 0{
                    keys.forEach { key in
                        newStr = str?.wp.filter(key)
                    }
                }
            }
            if base.markedTextRange() == nil {
                return newStr?.wp.subString(of: .init(0, count))
            }
            return str
        }).bind(to: base.rxText()).disposed(by: base.wp_inputNumberDisposeBag)
        return self
    }
    
    /// 数字输入 最小值0
    /// - Parameters:
    ///   - minNumCount: 小数位数
    ///   - maxValue: 最大值
    ///   - maxWarning: 超过最大值时提示 返回true将填充最大值 否则不填充
    /// - Returns: 语法糖
    @discardableResult
    func inputNumber(minNumCount:UInt = 2,
                     maxValue:Double? = nil,
                     inputCompleteCheck:Bool = true,
                     maxWarning:@escaping ((Base)->Bool) = {_ in true}) -> Self {
        base.wp_inputNumberDisposeBag = DisposeBag()
        let isXiaoShu = minNumCount > 0
        let isMax = maxValue != nil
        var last:String?

        base.rxText().map({ str in
            let regex = "^\\-?([1-9]\\d*|0)(\\.\\d{0,\(minNumCount)})?$"
            let res =  NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: str)
            var newStr = str?.wp.filter("-")

            if !isXiaoShu { // 不包含小数不能输入.
                newStr = newStr?.wp.filter(".")
            }
            let strValue = newStr?.wp.double ?? 0

            let strPoint = newStr?.wp.of(".")
            let isLastPoint = ((strPoint?.location ?? 0) != (newStr?.count ?? 0)  - 1) && (newStr?.count ?? 0) > 0

            if isMax {
                if strValue == maxValue{
                    newStr = maxValue?.wp.accuracy(length: Int(minNumCount))
                }else if strValue > maxValue!{
                    if maxWarning(base){
                        if minNumCount <= 0 {
                            newStr = Int(maxValue!).description
                        }else{
                            newStr = maxValue!.wp.accuracy(length: Int(minNumCount))
                        }
                    }else{
                        newStr = last
                    }
                }
            }

            if res || str == "" {
                let lastValue = last?.wp.double ?? 0
                if lastValue == strValue && lastValue != 0 && isLastPoint && newStr?.wp.minNumCount ?? 0 == minNumCount && minNumCount != 1{
                    if newStr?.count ?? 0 < last?.count ?? 0 {
                        last = newStr
                    }
                    return last
                }

                last = newStr
            }

            return last

        }).bind(to: base.rxText()).disposed(by: base.wp_inputNumberDisposeBag)

        
        base.inputComplete().flatMap { str in
            let point = str?.wp.of(".")
            let isLast = (str?.count ?? 0) - 1 == point?.location ?? 0
            if point?.location ?? 0 >= 1 && isLast && minNumCount > 0{
                return Observable<String?>.just(str?.wp.filter("."))
            }
            
            if inputCompleteCheck {
                let strValue = str?.wp.double ?? 0
                let newStr = strValue.wp.accuracy(length:Int(minNumCount))
                
                if strValue != 0 && newStr.count < str?.count ?? 0{
                    return Observable<String?>.just(newStr)
                }
            }

            return Observable<String?>.empty()
        }.bind(to: base.rxText()).disposed(by: base.wp_inputNumberDisposeBag)

        return self
    }
}





/*
 let regex = "^\\-?([1-9]\\d*|0)(\\.\\d{0,\(minNumCount)})?$"
 let res =  NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: str)
 var newStr = str
 
 let pointStr = str ?? ""
 let valueLoc = str?.wp.of(".")
 let isPoint = valueLoc?.length ?? 0 == 1
 let valuePoint = pointStr.count - (valueLoc?.location ?? 0) - 1

 
 if minNumCount <= 0 {
     newStr = str?.wp.filter(".")
     if let valueRange = range {
         if valueRange.lowerBound == 0 {
             newStr = newStr?.wp.filter("0")
             newStr = newStr?.wp.filter("-")
         }
     }else{
         
         if str == "-0"{
             newStr = "-"
         }
     }
 }
 let strValue = NumberFormatter().number(from: newStr ?? "0")?.doubleValue ?? 0

 if let valueRange = range{
     if res || newStr == "" || newStr == "-"{
         if strValue > valueRange.upperBound{
             if maxWarning(base){
                 if minNumCount <= 0 {
                     newStr = Int(valueRange.upperBound).description
                 }else{
                     newStr = valueRange.upperBound.description
                 }
             }
             return newStr
         }
         
         if valueRange.lowerBound > 0{
             if str == "-"{
                 newStr = ""
             }
             
             if minNumCount == 0{
                 if str == "."{
                     newStr = ""
                 }
             }
         }
         
         if valueRange.lowerBound == 0{
             if str == "-"{
                 newStr = ""
             }

             if str == "0"{
                 newStr = str
             }
             
             if str == "0."{
                 newStr = str
             }
         }
         
         if minNumCount == 0 && strValue < valueRange.lowerBound && str?.count ?? 0 > 0{
             if minWarning(base){
                 if minNumCount <= 0{
                     newStr = Int(valueRange.lowerBound).description
                 }else{
                     newStr = valueRange.lowerBound.description
                 }
             }
             
             last = newStr
             return newStr
         }


         if strValue != 0 {
             if strValue < valueRange.lowerBound {
                 if minWarning(base){
                     if minNumCount <= 0{
                         newStr = Int(valueRange.lowerBound).description
                     }else{
                         newStr = valueRange.lowerBound.description
                     }
                 }
             }
         }
         

         last = newStr
         return newStr
     }
 }else{
     
     if res || newStr == "" || newStr == "-"{
         last = newStr
         return newStr
     }
 }
 */
