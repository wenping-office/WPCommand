//
//  UIIViewController+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/9.
//

import UIKit

private var UIImagePickerControllerDelegatePointer = "UIImagePickerControllerDelegatePointer"

public extension UIImagePickerController {
    var wp_delegate: WPImagePickerControllerDelegate {
        set {
            WPRunTime.set(self, newValue, withUnsafePointer(to: &UIImagePickerControllerDelegatePointer, {$0}), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            delegate = newValue
        }
        get {
            guard let wp_delegate: WPImagePickerControllerDelegate = WPRunTime.get(self, withUnsafePointer(to: &UIImagePickerControllerDelegatePointer, {$0})) else {
                let wp_delegate = WPImagePickerControllerDelegate()
                self.wp_delegate = wp_delegate
                return wp_delegate
            }
            return wp_delegate
        }
    }
}

public extension UIImagePickerController {
    /// 选择图片
    /// - Parameters:
    ///   - vc: 弹出的VC
    ///   - source: 从哪选择
    ///   - allowsEditing: 是否需要编辑
    ///   - complete: 选择后回调
    static func selected(vc: UIViewController? = nil,
                         source: UIImagePickerController.SourceType,
                         allowsEditing: Bool = false,
                         complete: @escaping (UIImagePickerController, [UIImagePickerController.InfoKey: Any])->Void)
    {
        let picker = self.init()
        picker.wp_delegate.didFinishPickingMedia = complete
        picker.wp_delegate.didCancel = { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        picker.sourceType = source
        picker.allowsEditing = allowsEditing
        if vc != nil {
            vc?.present(picker, animated: true, completion: nil)
        } else {
            UIApplication.wp.keyWindow?.rootViewController?.present(picker, animated: true, completion: nil)
        }
    }

    /// 拍照
    /// - Parameters:
    ///   - vc: 弹出的VC
    ///   - allowsEditing: 是否需要编辑
    ///   - complete: 选择后回调
    static func capture(vc: UIViewController? = nil,
                        allowsEditing: Bool = false,
                        complete: @escaping (UIImagePickerController, [UIImagePickerController.InfoKey: Any])->Void)
    {
        selected(vc: vc, source: .camera, allowsEditing: allowsEditing, complete: complete)
    }
}

public class WPImagePickerControllerDelegate: NSObject {
    /// 图片选择完成后调
    public var didFinishPickingMedia: ((UIImagePickerController, [UIImagePickerController.InfoKey: Any])->Void)?
    /// 点击了取消
    public var didCancel: ((UIImagePickerController)->Void)?
}

extension WPImagePickerControllerDelegate: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        didFinishPickingMedia?(picker, info)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancel?(picker)
    }
}
