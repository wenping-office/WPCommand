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
    class DefaultNavigationItem: WPBaseView,WPMenuNavigationViewProtocol {
        // 内容标题
        public let normalLabel : UILabel = .init()
        /// 选中时候label
        public let selectedLabel : UILabel = .init()
        /// 背景视图
        public let backgroundView : UIImageView = UIImageView()
        /// 选中的背景视图
        public let selectedBackgroundView : UIImageView = UIImageView()
        /// 线条
        public let lineView = UIView()
        /// 选中样式
        let style : Style

        public init(style : Style) {
            self.style = style
            super.init(frame: .zero)
            
            normalLabel.text = style.text.title
            normalLabel.textAlignment = .center
            
            switch style.text.fontOption {
            case .custom:
                normalLabel.font = .init(name: style.text.font.fontName, size: style.text.defaultSize)
            case .system(let weight):
                normalLabel.font = .systemFont(ofSize: style.text.defaultSize,weight: weight)
            }

            normalLabel.textColor = style.text.normalColor
            normalLabel.backgroundColor = .clear
            
            selectedLabel.text = style.text.title
            selectedLabel.textAlignment = .center
            
            switch style.text.fontOption {
            case .custom:
                selectedLabel.font = .init(name: style.text.font.fontName, size: style.text.defaultSize)
            case .system(let weight):
                selectedLabel.font = .systemFont(ofSize: style.text.defaultSize,weight: weight)
            }
            
            selectedLabel.textColor = style.text.selectedColor
            selectedLabel.backgroundColor = .clear
            selectedLabel.alpha = 0
            
            backgroundView.image = style.background.normalImage
            
            selectedBackgroundView.alpha = 0
            selectedBackgroundView.image = style.background.selectedImage
            
            lineView.backgroundColor = style.line?.color
            lineView.alpha = 0
            
            lineView.isHidden = style.line == nil
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
           
            if  let line = style.line{
                lineView.snp.makeConstraints { make in
                    make.height.equalTo(style.line!.height)
                    if let width = line.width {
                        make.centerX.equalToSuperview()
                        make.width.equalTo(width)
                    }else{
                        make.left.equalTo(line.edge.left)
                        make.right.equalTo(-line.edge.right)
                    }
                    make.bottom.equalToSuperview()
                }
            }
        }

        public func menuItemWidth() -> CGFloat {
            if style.text.width != nil {
                return style.text.width!
            }else{
                return style.text.title.wp.width(style.text.font, CGFloat.greatestFiniteMagnitude) + style.text.edge.left + style.text.edge.right + 1
            }
        }
       
        public func didHorizontalRolling(with percentage: Double) {
            let newSize = style.text.defaultSize + (style.text.transitionNumber * style.text.font.pointSize) * percentage

            switch style.text.fontOption {
            case .custom:
                normalLabel.font = .init(name: style.text.font.fontName, size: newSize)
                selectedLabel.font = .init(name: style.text.font.fontName, size: newSize)
            case .system(let weight):
                normalLabel.font = .systemFont(ofSize: newSize, weight: weight)
                selectedLabel.font = .systemFont(ofSize: newSize, weight: weight)
            }
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
        let edge:WPMenuView.ContentEdge
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
                    edge:WPMenuView.ContentEdge,
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
                                _ edge:WPMenuView.ContentEdge = .init(left: 0, right: 0),
                                color:UIColor)->Self{
            return .init(width: width,
                         height: height,
                         edge: edge,
                         color: color)
        }
    }

    struct Text{
        public enum FontOption {
            /// 系统字体
            case system(weight:UIFont.Weight = .light)
            /// 自定义字体
            case custom
        }
        
        /// 宽 如果设置了将根据标题适配、并且contentEdge将失效
        public let width : CGFloat?
        /// 左右内边距
        public let edge : WPMenuView.ContentEdge
        /// 标题
        public let title : String
        /// 字体 注：fontSize =  fontSize + fontTransitionNumber * fontSize
        public let font : UIFont
        /// 字体选项
        public let fontOption: FontOption
        /// 默认字体颜色
        public let normalColor : UIColor
        /// 选中字体颜色
        public let selectedColor : UIColor
        /// 过渡系数 默认0.5 取值范围 0～1
        public let transitionNumber : CGFloat
        /// 默认字体大小
        var defaultSize : CGFloat{
            return font.pointSize - font.pointSize * transitionNumber
        }
        
        /// 文本信息
        /// - Parameters:
        ///   - title: 标题
        ///   - font: 字体大小
        ///   - fontWeight: 字体
        ///   - normalColor: 默认颜色
        ///   - selectedColor: 选中颜色
        ///   - transitionNumber: 过渡系数
        ///   - width: 为nil 时将自动适配宽度，受contentEdge影响，否则为固定宽度
        ///   - edge: 左右边距
        public init(title:String,
                    font:UIFont,
                    fontOption:FontOption,
                    width : CGFloat?,
                    normalColor:UIColor,
                    selectedColor:UIColor,
                    edge:WPMenuView.ContentEdge ,
                    transitionNumber:CGFloat){
            self.title = title
            self.font = font
            self.fontOption = fontOption
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
                                _ font : UIFont = .systemFont(ofSize: 15),
                                _ width : CGFloat? = nil,
                                normalColor:UIColor = .black,
                                selectedColor:UIColor = .black,
                                edge:WPMenuView.ContentEdge = .init(left: 20, right: 20),
                                transitionNumber:CGFloat = 0.3)->Self{
            return .init(title: title,
                         font: font, fontOption: .system(weight: .light),
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
        public let line : Line?
        
        /// 样式
        /// - Parameters:
        ///   - text: 文本信息
        ///   - background: 背景
        ///   - line 下滑线 nil 时隐藏
        public init(_ text:Text,
                    background:Background = .background(),
                    line:Line? = nil){
            self.text = text
            self.background = background
            self.line = line
        }
    }
}
