//
//  WPMenuViewINavigationProtol.swift
//  WPCommand
//
//  Created by WenPing on 2021/9/13.
//

import UIKit

public protocol WPMenuNavigationViewProtocol: WPMenuViewChildViewProtocol, UIView {
    /// 每一个菜单item的width
    func menuItemWidth() -> CGFloat
}

public extension WPMenuNavigationViewProtocol{
    /// 默认标题 自定义标题需要继承 WPMenuNavigationViewProtocol
    static func `default`(_ style : WPMenuView.DefaultNavigationItem.Style)->Self{
        return WPMenuView.DefaultNavigationItem.init(style: style) as! Self
    }
}

public extension WPMenuView{
    /// 默认导航栏
    final class DefaultNavigationItem: WPBaseView,WPMenuNavigationViewProtocol {
        // 内容标题
        let normalLabel : UILabel = .init()
        /// 选中时候label
        let selectedLabel : UILabel = .init()
        /// 背景视图
        let backgroundView : UIImageView = UIImageView()
        /// 选中的背景视图
        let selectedBackgroundView : UIImageView = UIImageView()
        /// 线条
        let lineView = UIView()
        /// 选中样式
        private let style : Style

        init(style : Style) {
            self.style = style
            super.init(frame: .zero)
            
            normalLabel.text = style.text.title
            normalLabel.textAlignment = .center
            normalLabel.font = UIFont.systemFont(ofSize: style.text.defaultSize, weight: style.text.fontWeight)
            normalLabel.textColor = style.text.normalColor
            normalLabel.backgroundColor = .clear
            
            selectedLabel.text = style.text.title
            selectedLabel.textAlignment = .center
            selectedLabel.font = UIFont.systemFont(ofSize: style.text.defaultSize, weight: style.text.fontWeight)
            selectedLabel.textColor = style.text.selectedColor
            selectedLabel.backgroundColor = .clear
            selectedLabel.alpha = 0
            
            backgroundView.image = style.background.normalImage
            
            selectedBackgroundView.alpha = 0
            selectedBackgroundView.image = style.background.selectedImage
            
            lineView.backgroundColor = style.line.color
            lineView.alpha = 0
        }

        public override func initSubView() {
            addSubview(backgroundView)
            addSubview(selectedBackgroundView)
            addSubview(normalLabel)
            addSubview(selectedLabel)
            addSubview(lineView)
        }
       
        public override func initSubViewLayout() {
            normalLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(style.text.edge.left)
                make.right.equalToSuperview().offset(-style.text.edge.right)
            }
           
            selectedLabel.snp.makeConstraints { make in
                make.edges.equalTo(normalLabel)
            }

            backgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            selectedBackgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
           
            lineView.snp.makeConstraints {[weak self] make in
                guard
                    let self = self
                else { return }
                make.height.equalTo(style.line.height)
               
                if let width = self.style.line.width {
                    make.centerX.equalToSuperview()
                    make.width.equalTo(width)
                }else{
                    make.left.equalTo(self.style.line.edge.left)
                    make.right.equalTo(-self.style.line.edge.right)
                }
                make.bottom.equalToSuperview()
            }
        }

        public func menuItemWidth() -> CGFloat {
            if style.text.width != nil {
                return style.text.width!
            }else{
                return style.text.title.wp.width(UIFont.systemFont(ofSize: style.text.fontSize + 1, weight: style.text.fontWeight), CGFloat.greatestFiniteMagnitude) + style.text.edge.left + style.text.edge.right
            }
        }
       
        public func didHorizontalRolling(with percentage: Double) {
            let newSize = style.text.defaultSize + (style.text.transitionNumber * style.text.fontSize) * percentage

            normalLabel.font = UIFont.systemFont(ofSize: newSize, weight: style.text.fontWeight)
            
            selectedLabel.font = UIFont.systemFont(ofSize: newSize, weight: style.text.fontWeight)
            
            selectedLabel.alpha = percentage
           
            backgroundView.alpha = 1 - percentage
            
            normalLabel.alpha = 1 - percentage
            
            selectedBackgroundView.alpha = percentage
           
            lineView.alpha = percentage
            
        }
    }
}

public extension WPMenuView.DefaultNavigationItem{
    /// 线条
    struct Line {
        let height:CGFloat
        /// 宽度
        let width:CGFloat?
        /// 边距
        let edge:ContentEdge
        /// 颜色
        let color : UIColor?
        
        /// 初始化线条
        /// - Parameters:
        ///   - width: 固定宽度
        ///   - edge: 边距
        ///   - color: 颜色
        ///   - height: 高
        public init(width:CGFloat?,
                    height:CGFloat,
                    edge:ContentEdge,
                    color:UIColor){
            self.height = height
            self.width = width
            self.edge = edge
            self.color = color
        }
        
        /// 初始化线条
        /// - Parameters:
        ///   - width: 固定宽度
        ///   - edge: 边距
        ///   - color: 颜色
        ///   - height: 高
        public static func line(_ width:CGFloat? = 44,
                                _ height:CGFloat = 2,
                                _ edge:ContentEdge = .init(left: 0, right: 0),
                                color:UIColor)->Self{
            return .init(width: width,
                         height: height,
                         edge: edge,
                         color: color)
        }
    }

    struct Text{
        /// 宽 如果设置了将根据标题适配、并且contentEdge将失效
        public let width : CGFloat?
        /// 左右内边距
        public let edge : ContentEdge
        /// 标题
        public let title : String
        /// 字体最终大小 注：fontSize =  fontSize + fontTransitionNumber * fontSize
        public let fontSize : CGFloat
        /// 字体
        public let fontWeight : UIFont.Weight
        /// 默认字体颜色
        public let normalColor : UIColor
        /// 选中字体颜色
        public let selectedColor : UIColor
        /// 过渡系数 默认0.5 取值范围 0～1
        public let transitionNumber : CGFloat
        /// 默认字体大小
        public var defaultSize : CGFloat{
            return fontSize - fontSize * transitionNumber
        }
        
        /// 文本信息
        /// - Parameters:
        ///   - title: 标题
        ///   - fontSize: 字体大小
        ///   - fontWeight: 字体
        ///   - normalColor: 默认颜色
        ///   - selectedColor: 选中颜色
        ///   - transitionNumber: 过渡系数
        ///   - width: 为nil 时将自动适配宽度，受contentEdge影响，否则为固定宽度
        ///   - edge: 左右边距
        public init(title:String,
                    fontSize:CGFloat,
                    fontWeight:UIFont.Weight,
                    width : CGFloat?,
                    normalColor:UIColor,
                    selectedColor:UIColor,
                    edge:ContentEdge ,
                    transitionNumber:CGFloat){
            self.title = title
            self.fontSize = fontSize
            self.fontWeight = fontWeight
            self.normalColor = normalColor
            self.selectedColor = selectedColor
            self.transitionNumber = transitionNumber
            self.width = width
            self.edge = edge
        }
        
        /// 文本信息
        /// - Parameters:
        ///   - title: 标题
        ///   - fontSize: 字体大小
        ///   - fontWeight: 字体
        ///   - normalColor: 默认颜色
        ///   - selectedColor: 选中颜色
        ///   - transitionNumber: 过渡系数
        ///   - width: 为nil 时将自动适配宽度，受contentEdge影响，否则为固定宽度
        ///   - edge: 左右边距
        public static func text(_ title:String,
                                _ fontSize:CGFloat,
                                _ fontWeight:UIFont.Weight,
                                _ width : CGFloat? = nil,
                                normalColor:UIColor = .black,
                                selectedColor:UIColor = .black,
                                edge:ContentEdge = .init(left: 20, right: 20),
                                transitionNumber:CGFloat = 0.3)->Self{
            return .init(title: title,
                         fontSize: fontSize,
                         fontWeight: fontWeight,
                         width: width,
                         normalColor: normalColor,
                         selectedColor: selectedColor,
                         edge: edge,
                         transitionNumber: transitionNumber)
        }
    }

    /// 背景相关
    struct Background {
        /// 背景图
        public let normalImage : UIImage?
        /// 选中背景图
        public let selectedImage : UIImage?
        
        /// 背景图片
        /// - Parameters:
        ///   - normalImage: 背景图片
        ///   - selectedImage: 选中图片
        ///   - transitionNumber: 过渡系数
        public init(normalImage:UIImage?,
                    selectedImage:UIImage?){
            self.normalImage = normalImage
            self.selectedImage = selectedImage
        }
        
        /// 背景图片
        /// - Parameters:
        ///   - normalImage: 背景图片
        ///   - selectedImage: 选中图片
        ///   - transitionNumber: 过渡系数
        public static func background(_ normalImage:UIImage? = nil,
                                      _ selectedImage:UIImage? = nil)->Self{
            return .init(normalImage: normalImage,
                         selectedImage: selectedImage)
        }
    }

    struct Style{
        /// 字体相关
        public let text : Text
        /// 背景相关
        public let background:Background
        /// 线条样式
        public let line : Line
        
        /// 样式
        /// - Parameters:
        ///   - text: 文本信息
        ///   - background: 背景
        public init(_ text:Text,
                    background:Background = .background(),
                    line:Line = .line(color: .orange)){
            self.text = text
            self.background = background
            self.line = line
        }
    }
    
    /// 左右内容边距
    struct ContentEdge{
        /// 左边内容内边距
        public let left : CGFloat
        /// 右边内容内编剧
        public let right : CGFloat
        
        ///  边距
        /// - Parameters:
        ///   - left: 左边距
        ///   - right : 右边距
        public init(left:CGFloat,
                    right:CGFloat){
            self.left = left
            self.right = right
        }
    }
}
