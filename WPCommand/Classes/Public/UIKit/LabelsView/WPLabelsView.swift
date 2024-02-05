//
//  WPLabelsView.swift
//  WPCommand
//
//  Created by WenPing on 2022/2/21.
//

import UIKit

public protocol WPLabelsItemView:UIView{
    /// 最大的宽
    func labelItemWidth(with data:Any) -> CGFloat
}

public protocol WPLabelsViewDelegate : AnyObject{
    /// 选中某个标签回调
    func labelsView(didSelectAt index: Int,with itemView:WPLabelsItemView, data:Any)
}

public class WPLabelsView<V:WPLabelsItemView>: WPBaseView {
    /// 每一个item的高度
    let itemHight : CGFloat
    /// 最多展示几行
    public var numberOfLines : Int = 0{
        didSet{
            resetSubItemsFrame()
        }
    }
    /// 间距
    public let spacing : CGFloat
    /// 行间距
    public let rowSpacing : CGFloat
    /// 数据源
    public private(set) var data : [Any] = []
    /// 代理
    public weak var delegate : WPLabelsViewDelegate?
    /// 内容高度
    public var contentHeight : CGFloat{
        for view in subviews.reversed() {
            if !view.isHidden {
                return view.wp.maxY
            }
        }
        return 0
    }
    
    public var estimatedWidth : CGFloat?

    /// 初始化标签视图
    /// - Parameters:
    ///   - itemHeight: item高度
    ///   - spacing: 列间距
    ///   - rowSpacing: 行间距
    ///   - estimatedWidth: 预估最大宽，如果有值按照预估值计算
    public init(itemHeight: CGFloat,
                estimatedWidth : CGFloat? = nil,
                spacing:CGFloat = 10,
                rowSpacing:CGFloat = 10) {
        self.itemHight = itemHeight
        self.spacing = spacing
        self.rowSpacing = rowSpacing
        self.estimatedWidth = estimatedWidth
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }

    /// 设置数据源
    /// - Parameter data: 数据类型
    public func set(data:[Any]){
        self.data = data
        wp.removeAllSubView()
        
        for index in 0..<data.count {
            let elmt = data[index]
            let subView = V.init(frame: .zero).wp.isUserInteractionEnabled(true).value()
            subView.frame = .init(x: 0, y: 0, width: subView.labelItemWidth(with: elmt), height: itemHight)
            addSubview(subView)
            let tap = UITapGestureRecognizer()
            subView.addGestureRecognizer(tap)
            tap.rx.event.subscribe(onNext: {[weak self] _ in
                self?.delegate?.labelsView(didSelectAt: index, with: subView, data: elmt)
            }).disposed(by: subView.wp.disposeBag)
        }
        layoutIfNeeded()
    }

    /// 删除某个标签
    public func remove(at index:Int){
        data.wp_remove(at: index)
        reloadData()
    }

    /// 增加标签
    public func append(_ elmt : Any){
        data.append(elmt)
        reloadData()
    }

    /// 插入某个标签
    public func insert(_ elmt : Any,at:Int){
        data.wp_insert(elmt, at: at)
        reloadData()
    }

    /// 刷新数据源
    public func reloadData(){
        set(data: data)
    }

    private func resetSubItemsFrame(){
        let maxWidth = estimatedWidth != nil ? estimatedWidth! : self.wp.width
        var y : CGFloat = 0
        var row : CGFloat = 0
        var rowX : CGFloat = 0

        subviews.forEach { elmt in
            elmt.wp_orgin = .zero
            elmt.isHidden = false
        }

        for index in 0..<subviews.count {
            let lastX = subviews.wp_get(of: index - 1)?.wp_maxX ?? 0

            let view = subviews[index] as! V
            let width = view.labelItemWidth(with: data[index])

            if lastX + width + spacing > maxWidth{
                row = row + 1
                rowX = 0
            }

            y = row * (itemHight + rowSpacing)

            view.wp_orgin = .init(x: rowX, y: y)

            rowX = spacing + width + rowX

            view.isHidden = (numberOfLines != 0 && Int(row) + 1 > numberOfLines)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        resetSubItemsFrame()
    }
}
