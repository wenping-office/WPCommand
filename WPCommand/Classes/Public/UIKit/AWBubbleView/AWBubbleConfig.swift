//
//  AWBubbleConstant.swift
//  AWBubble
//
//  Created by Mccc on 2022/11/21.
//

import Foundation
import UIKit



public struct AWBubbleConfig {
    public static var shared = AWBubbleConfig()
    
    /// 气泡外观相关的配置
    public var appearance = AWBubbleConfig.Appearance()
    
    /// 文字的相关设置
    public var textSetting = AWBubbleConfig.TextSetting()
    
    /// 气泡的箭头
    public var arrow = AWBubbleConfig.Arrow()
    
    /// 气泡的最大宽度
    public var maxWidth: CGFloat = 282
    /// 气泡文案最大高度（不影响自定义）
    public var maxHeight: CGFloat = UIScreen.main.bounds.size.height * 0.35
    
    /// 默认的反弹距离
    public var defaultBounceOffset = CGFloat(8)
    /// 默认的浮动距离
    public var defaultFloatOffset = CGFloat(8)
    /// 默认的跳动缩放比例
    public var defaultPulseOffset = CGFloat(1.1)
    

}



extension AWBubbleConfig {
    
    public struct Appearance {
        // 气泡
        /// 气泡的背景颜色
        public var backgroundColor = UIColor.white
        /// 气泡圆角的设置
        public var cornerRadius = CGFloat(4.0)
        /// 气泡边框颜色
        public var borderColor = UIColor.clear
        /// 气泡边框宽度 (设置过大，会出现UI问题)
        public var borderWidth = CGFloat(0.0)
        /// 气泡阴影的颜色
        public var shadowColor: UIColor = UIColor.init(white: 0, alpha: 0.8)
        /// 气泡阴影的偏移量
        public var shadowOffset: CGSize = .zero
        /// 气泡阴影的圆角
        public var shadowRadius: Float = 4
        /// 气泡阴影的不透明度
        public var shadowOpacity: Float = 0.2
        /// 气泡的内边距
        public var edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}


extension AWBubbleConfig {
    
    public struct TextSetting {
        // 气泡文字
        /// 气泡上的文字大小
        public var font = UIFont.systemFont(ofSize: 12)
        /// 气泡上的文字颜色
        public var textColor = UIColor.red//color212121
        /// 气泡字体的`NSTextAlignment`
        public var textAlignment = NSTextAlignment.left
    }
}

extension AWBubbleConfig {
    /// 气泡箭头
    public struct Arrow {
        /// 气泡箭头的大小
        public var arrowSize = CGSize(width: 13, height: 7)
        /// 气泡箭头的圆角
        public var arrowRadius = CGFloat(0.0)
        /// 气泡箭头的偏移量
        public var arrowOffset: AWBubble.ArrowOffset = .auto(20)
        
    }
}

