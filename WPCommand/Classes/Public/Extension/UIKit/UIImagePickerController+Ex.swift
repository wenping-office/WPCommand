//
//  UIIViewController+Ex.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/9.
//

import UIKit


class WPImagePickerControllerDelegate: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    /// 图片选择完成后调
    var didFinishPickingMedia : (([UIImagePickerController.InfoKey : Any]) -> Void)? = nil

    /// 图片选择完成
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.didFinishPickingMedia != nil ? didFinishPickingMedia!(info) : print()
    }
}


public extension UIImagePickerController{
    
    /// 选择图片
    /// - Parameters:
    ///   - vc: 弹出的VC
    ///   - source: 从哪选择
    ///   - allowsEditing: 是否需要编辑
    ///   - complete: 选择后回调
    static func selected(vc:UIViewController? = nil,
                        source:UIImagePickerController.SourceType,
                        allowsEditing:Bool = false,
                        complete:@escaping ([UIImagePickerController.InfoKey : Any])->Void){
        
        let birage = WPImagePickerControllerDelegate()
        birage.didFinishPickingMedia = complete
        let picker = self.init()
        picker.delegate = birage
        picker.sourceType = source
        picker.allowsEditing = allowsEditing
        if vc != nil {
            vc?.present(picker, animated: false, completion: nil)
        }else{
            UIApplication.shared.wp_topWindow.rootViewController?.present(picker, animated: true, completion: nil)
        }
    }
    
    /// 拍照
    /// - Parameters:
    ///   - vc: 弹出的VC
    ///   - allowsEditing: 是否需要编辑
    ///   - complete: 选择后回调
    static func capture(vc:UIViewController? = nil,
                                     allowsEditing:Bool = false,
                                     complete:@escaping ([UIImagePickerController.InfoKey : Any])->Void){
        selected(vc: vc, source: .camera, allowsEditing: allowsEditing, complete: complete)
    }
}

