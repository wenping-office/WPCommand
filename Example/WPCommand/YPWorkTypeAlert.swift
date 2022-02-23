//
//  WPWorkTypeAlert.swift
//  WPCommand_Example
//
//  Created by WenPing on 2022/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

extension YPWorkTypeAlert{
    enum Style {
        /// 二级选择
        case two
        /// 三级选择
        case three
    }
}

class YPWorkTypeAlert: WPBaseView,YPAlertProtocol,WPLabelsViewDelegate {
    /// 顶部条
    let topBar = YPAlertTopBar()
    /// 最多选择二级标签几个
    var maxLevelTwo : Int = 999
    /// 最多三级标签几个
    var maxLevelThree : Int = 999
    /// 标签视图
    private let labelsView = WPLabelsView<LabelView>.init(itemHeight: 28, spacing: 12, rowSpacing: 8)
    /// 左边tabel
    private let leftTableView = UITableView()
    /// 右边table
    private let rightTableView = UITableView.init(frame: .zero, style: .grouped)
    /// 分割线
    private let line1 = UIView()
    /// 分割线
    private let line2 = UIView()
    /// 左边数据源
    private var leftSource : [Item] = []
    /// 右边数据源
    private var rightSource : [Item] = []
    /// 列表样式
    private let style : Style
    /// 选择后回调
    private var complete : (([Item])->Void)?
    ///  默认选项
    private var defaultItems : [Item] = []
    /// 是否第一次设置默认值
    private var oneSetDefault = true
    /// 占位图
    private var placeholderView = PlacehloderView()

    init(style:Style) {
        self.style = style
        super.init(frame: .zero)
    }

    override func observeSubViewEvent() {
        topBar.cancelBtn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] in
            self?.dismiss()
        }).disposed(by: wp.disposeBag)
        
        topBar.qureBtn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] in
            guard
                let weakSelf = self,
                let items = weakSelf.labelsView.data as? [Item]
            else { return }
            weakSelf.dismiss { state in
                if state == .didPop {
                    weakSelf.complete?(items)
                }
            }
        }).disposed(by: wp.disposeBag)
        
        placeholderView.btn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] _ in
            self?.dismiss { state in
                if state == .didPop {
                    self?.placeholderView.placehloder?.callBack?()
                }
            }
        }).disposed(by: wp.disposeBag)
    }

    override func initSubView() {
        backgroundColor = .white

        if #available(iOS 15.0, *) {
            leftTableView.sectionHeaderTopPadding = 0
            rightTableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        line1.backgroundColor = .wp.initWith(239, 241, 246, 1)
        line2.backgroundColor = .wp.initWith(239, 241, 246, 1)

        labelsView.delegate = self
        rightTableView.backgroundColor = .white
        rightTableView.delaysContentTouches = false
        rightTableView.sectionFooterHeight = 0
        leftTableView.wp.register(with: LeftCell.self)
        rightTableView.wp.register(with: RightCell.self)
        rightTableView.wp.registerHeaderFooter(with: RightHeaderFooterView.self)
        rightTableView.estimatedRowHeight = 40
        leftTableView.separatorStyle = .none
        rightTableView.separatorStyle = .none
        leftTableView.showsVerticalScrollIndicator = false
        leftTableView.backgroundColor = .wp.initWith(245, 246, 250, 1)
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.tag = 1
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.tag = 2
        placeholderView.isHidden = true
        
        addSubview(topBar)
        addSubview(line1)
        addSubview(labelsView)
        addSubview(line2)
        addSubview(leftTableView)
        addSubview(rightTableView)
        addSubview(placeholderView)
    }

    override func initSubViewLayout() {
        topBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        line1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
            make.height.equalTo(0.5)
        }

        labelsView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(line1.snp.bottom).offset(12)
            make.bottom.equalTo(line2.snp.top).offset(-12)
            make.height.greaterThanOrEqualTo(0)
        }
        
        line2.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        leftTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(line2.snp.bottom)
            make.width.equalTo(137)
            make.bottom.equalToSuperview().offset(-200)
            make.height.equalTo(UIScreen.main.bounds.height * 0.65)
        }
        
        rightTableView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalTo(leftTableView)
            make.left.equalTo(leftTableView.snp.right)
        }
        
        placeholderView.snp.makeConstraints { make in
            make.edges.equalTo(rightTableView)
        }
    }
    
    func stateDidUpdate(state: YPAlertManager.State) {
        if state == .willShow {
            if oneSetDefault {
                wp.corner([.topLeft,.topRight], radius: 6)
                labelsView.set(data: defaultItems)
                updateSize()
                oneSetDefault = false
            }
        }
    }

    func alertInfo() -> YPAlertManager.Alert {
        return .init(.default, location: .bottomToFill(200), showDuration: 0.3, direction: .bottom, dismissDuration: 0.3)
    }
    
    func didSelectedLeft(with row:Int){
        leftSource.forEach { elmt in
            elmt.isSelected = false
        }

        let elmt = leftSource[row]
        elmt.isSelected = true
        rightSource = elmt.subItems
        rightTableView.reloadData()
        leftTableView.reloadData()
        placeholderView.isHidden = (elmt.placeholder != nil) ? false : true
        placeholderView.placehloder = elmt.placeholder
    }
    
    func didSelectedRight(with row:Int){
        let elmt = rightSource[row]
        
        switch style{
            case.two:
            if !checkLevleTow() && !elmt.isSelected {
                print("超过最大可选择工种数量")
                return
            }
                elmt.isSelected = !elmt.isSelected

                if elmt.isSelected {
                    addLabels(with: elmt)
                }else{
                    remove(with: elmt)
                }
            case .three:
                elmt.isOpen = !elmt.isOpen
        }

        rightTableView.reloadData()
        leftTableView.reloadData()
    }
    
    func addLabels(with item:Item){
        labelsView.append(item)
        updateSize()
    }
    
    func remove(with item:Item){
        if let index = labelsView.data.wp_index(of: { elmt in
            if let elmtItem = elmt as? Item{
                return elmtItem.text == item.text
            }
            return false
        }){
            labelsView.remove(at: Int(index))
            updateSize()
        }
    }
    
    func updateSize(){
        labelsView.snp.updateConstraints { make in
            if labelsView.data.count > 0 {
                make.top.equalTo(line1.snp.bottom).offset(12)
                make.bottom.equalTo(line2.snp.top).offset(-12)
            }else{
                make.top.equalTo(line1.snp.bottom).offset(0)
                make.bottom.equalTo(line2.snp.top).offset(0)
            }
            make.height.greaterThanOrEqualTo(labelsView.contentHeight)
        }
        YPAlertManager.default.update()
        
        leftTableView.reloadData()
        rightTableView.reloadData()
    }

    func labelsView(didSelectAt index: Int, with itemView: WPLabelsItemView, data: Any) {
        if let item = data as? Item {
            // 便利列表数据
            leftSource.forEach { one in
                one.subItems.forEach { tow in
                    if style == .three {
                        tow.subItems.forEach { three in
                            if three.text == item.text {
                                three.isSelected = false
                            }
                        }
                        tow.isSelected = tow.isLabelSelected
                    }else{
                        if tow.text == item.text {
                            tow.isSelected = false
                        }
                    }
                }
            }
            remove(with: item)
        }
    }
    
    func checkLevleTow() -> Bool {
        var currentSelectedCount = 0
        leftSource.forEach { elmt in
            elmt.subItems.forEach { item in
                if item.isSelected {
                   currentSelectedCount += 1
                }
            }
        }
        return currentSelectedCount < maxLevelTwo
    }

    func checkLevelThree() -> Bool {
        return labelsView.data.count < maxLevelThree
    }

    static func show(in view:UIView? = nil,
                     config:(YPWorkTypeAlert)->Void,
                     style:Style,
                     source:[Item],
                     complete:@escaping (([Item])->Void)){
        let alert = YPWorkTypeAlert(style: style)
        config(alert)
        alert.leftSource = source
        alert.complete = complete

        var defaultItems : [Item] = []
        source.forEach { one in
            one.subItems.forEach { two in
                if style == .three {
                    two.subItems.forEach { three in
                        if three.isSelected {
                            defaultItems.append(three)
                        }
                    }
                    two.isSelected = two.isLabelSelected
                }else{
                    if two.isSelected {
                        defaultItems.append(two)
                    }
                }
            }
        }
        alert.defaultItems = defaultItems
        alert.show(in: view)
    }
}

extension YPWorkTypeAlert:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int{
        return tableView.tag == 1 ? 1 : rightSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return leftSource.count
        }else{
            return rightSource[section].isOpen && style == .three ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            let cell = tableView.wp.dequeue(of: LeftCell.self)!
            cell.set(item: leftSource[indexPath.row])
            return cell
        }else{
            let superItem = rightSource[indexPath.section]
            let cell = tableView.wp.dequeue(of: RightCell.self)!
            cell.set(item: superItem)
            cell.selectedChange = {[weak self] item in
                guard
                    let weakSelf = self
                else { return }

                if !weakSelf.checkLevleTow() && !item.isSelected && !superItem.isSelected {
                    print("超过最大可选择工种数量")
                    return
                }
                if !weakSelf.checkLevelThree() && !item.isSelected {
                    print("最大最大可选择标签数量")
                    return
                }

                item.isSelected = !item.isSelected
                superItem.isSelected = superItem.isLabelSelected
                if item.isSelected {
                    self?.addLabels(with: item)
                }else{
                    self?.remove(with: item)
                }
                self?.leftTableView.reloadData()
                self?.rightTableView.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 1 {
            return nil
        }else{
            let view = tableView.wp.dequeueHeaderFooter(of: RightHeaderFooterView.self)
            view?.style = style
            view?.tapCallBack = {[weak self] in
                self?.didSelectedRight(with: section)
            }
            view?.set(item: rightSource[section])
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return tableView.tag == 1 ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.tag == 1 ? 40 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            didSelectedLeft(with: indexPath.row)
        }
    }
}

extension YPWorkTypeAlert{
    class Placeholder {
        /// 图片
        var image : UIImage?
        /// 文本
        var text : String?
        /// 按钮标题
        var btnTitle : String?
        /// 回调
        var callBack : (()->Void)?
        
        init(
            image:UIImage? = .init(),
            text:String,
            btnTitle:String,
            callBack:@escaping ()->Void) {
            self.image = image
            self.text = text
            self.btnTitle = btnTitle
            self.callBack = callBack
        }
    }

    class Item {
        /// 显示文本
        var text : String = ""
        /// 是否选中
        var isSelected = false
        /// 附件
        var info : Any?
        /// 占位info，如果有的话右边将会展示占位图
        var placeholder : Placeholder?
        /// 子列表
        var subItems : [Item] = []
        /// 是否展开列表
        fileprivate var isOpen = false
        /// 标签选中
        fileprivate var isLabelSelected : Bool{
            var resualt = false
            subItems.forEach { elmt in
                if elmt.isSelected {
                    resualt = true
                    return
                }
            }
            return resualt
        }
    }
}

extension YPWorkTypeAlert{
    
    class PlacehloderView: WPBaseView {
        /// 图片
        let imageView = UIImageView()
        /// 文本
        let textLabel = UILabel()
        /// 按钮
        let btn = UIButton()
        
        var placehloder : Placeholder?{
            didSet{
                imageView.image = placehloder?.image
                textLabel.text = placehloder?.text
                btn.setTitle(placehloder?.btnTitle, for: .normal)
                btn.backgroundColor = .wp.initWith(229, 244, 255, 1)
            }
        }

        override func initSubView() {
            
            backgroundColor = .white
            textLabel.textAlignment = .center
            textLabel.numberOfLines = 0
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            btn.layer.cornerRadius = 4
            btn.setTitleColor(.wp.initWith(0, 146, 255, 1), for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 14)

            addSubview(imageView)
            addSubview(textLabel)
            addSubview(btn)
        }
        
        override func initSubViewLayout() {
            imageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(textLabel.snp.top).offset(-19)
            }
            
            textLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-40)
                make.left.lessThanOrEqualToSuperview().offset(14)
                make.right.lessThanOrEqualToSuperview().offset(-14)
            }
            
            btn.snp.makeConstraints { make in
                make.top.equalTo(textLabel.snp.bottom).offset(17)
                make.width.equalTo(144)
                make.height.equalTo(36)
                make.centerX.equalToSuperview()
            }
        }
    }

    class LabelView: WPBaseView,WPLabelsItemView {
        /// 标题
        let titleLabel = UILabel()
        /// 取消按钮
        let cancelBtn = UIButton()
        
        func labelItemWidth(with data: Any) -> CGFloat {
            if let item = data as? Item {
                titleLabel.text = item.text
                let width = item.text.wp.width(.systemFont(ofSize: 12), CGFloat.greatestFiniteMagnitude)
                return width + 8 + 28
            }
            return 40
        }
        
        override func initSubView() {
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.wp.initWith(0, 146, 255, 1).cgColor
            layer.cornerRadius = 4
            backgroundColor = .wp.initWith(230, 244, 255, 1)
            titleLabel.font = .systemFont(ofSize: 12)
            titleLabel.textColor = .wp.initWith(0, 146, 255, 1)
            addSubview(titleLabel)
            addSubview(cancelBtn)
            
            cancelBtn.backgroundColor = .wp.random
        }
        
        override func initSubViewLayout() {
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalTo(cancelBtn.snp.left)
                make.left.equalTo(6)
            }

            cancelBtn.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(28)
            }
        }
    }
    
    class LeftCell: UITableViewCell {
        /// 竖条
        let lineView = UIView()
        /// 圆点
        let spotView = UIView()
        /// 文本标签
        let titleLabel = UILabel()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            spotView.layer.cornerRadius = 2
            lineView.backgroundColor = .wp.initWith(0, 146, 255, 1)
            spotView.backgroundColor = .wp.initWith(0, 146, 255, 1)
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = .wp.initWith(0, 0, 0, 0.85)

            contentView.addSubview(lineView)
            contentView.addSubview(spotView)
            contentView.addSubview(titleLabel)
            
            lineView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.width.equalTo(3)
                make.top.equalTo(5)
                make.bottom.equalTo(-5)
            }
            
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(lineView.snp.right).offset(10)
                make.right.equalTo(spotView.snp.left).offset(-5)
            }
            
            spotView.snp.makeConstraints { make in
                make.width.height.equalTo(4)
                make.right.equalToSuperview().offset(-2)
                make.centerY.equalToSuperview()
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func set(item:Item){
            titleLabel.text = item.text
            spotView.isHidden = !item.isLabelSelected
            lineView.isHidden = !item.isSelected
            
            if item.isSelected {
                titleLabel.textColor = .wp.initWith(0, 146, 255, 1)
                backgroundColor = .white
            }else{
                titleLabel.textColor = .wp.initWith(0, 0, 0, 0.85)
                backgroundColor = .clear
            }
        }
    }
    
    class RightCell: UITableViewCell,WPLabelsViewDelegate {
        class LabelView : WPBaseView,WPLabelsItemView {
            /// 文本内容
            let textLabel = UILabel()

            override func initSubView() {
                layer.cornerRadius = 4
                textLabel.textAlignment = .center
                textLabel.font = .systemFont(ofSize: 14)
                addSubview(textLabel)
            }

            override func initSubViewLayout() {
                textLabel.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }

            func labelItemWidth(with data: Any) -> CGFloat {
                if let item = data as? Item {
                    textLabel.text = item.text
                    if item.isSelected {
                        backgroundColor = .wp.initWith(230, 244, 255, 1)
                        textLabel.textColor = .wp.initWith(0, 146, 255, 1)
                    }else{
                        textLabel.textColor = .wp.initWith(0, 0, 0, 0.85)
                        backgroundColor = .wp.initWith(245, 246, 250, 1)
                    }
                }
                return ((UIScreen.main.bounds.width - 137) - 3 * 8) * 0.5
            }
        }

        /// 标签视图
        let labelsView = WPLabelsView<LabelView>.init(itemHeight: 36, spacing: 8, rowSpacing: 8)
        /// 状态选中监听
        var selectedChange : ((Item)->Void)?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            labelsView.delegate = self
            selectionStyle = .none
            contentView.addSubview(labelsView)
            
            labelsView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalToSuperview().offset(8)
                make.right.equalToSuperview().offset(-8)
                make.height.greaterThanOrEqualTo(0).priority(.low)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func set(item:Item){
            labelsView.set(data: item.subItems)
            
            labelsView.snp.updateConstraints { make in
                make.height.greaterThanOrEqualTo(labelsView.contentHeight).priority(.low)
            }
        }
        
        func labelsView(didSelectAt index: Int, with itemView: WPLabelsItemView, data: Any) {
            guard
                let item = data as? Item
            else { return }
            selectedChange?(item)
        }
    }
    
    class RightHeaderFooterView: UITableViewHeaderFooterView {
        /// 文本标签
        let titleLabel = UILabel()
        /// 状态图片
        let stateImageView = UIButton()
        /// 按钮层
        let btn = UIButton()
        /// 点击回调
        var tapCallBack : (()->Void)?
        /// 选中样式
        var style : YPWorkTypeAlert.Style = .two
        
        override init(reuseIdentifier: String?){
            super.init(reuseIdentifier: reuseIdentifier)
            
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = .wp.initWith(0, 0, 0, 0.85)
            contentView.addSubview(titleLabel)
            contentView.addSubview(stateImageView)
            contentView.addSubview(btn)
            
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.right.equalTo(stateImageView.snp.left).offset(-8).priority(.low)
            }

            stateImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-8)
                make.width.height.equalTo(12)
            }
            
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview().priority(.low)
            }

            btn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] _ in
                self?.tapCallBack?()
            }).disposed(by: wp.disposeBag)
            
            stateImageView.backgroundColor = .wp.random
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func set(item:Item){
            titleLabel.text = item.text
            
            let selected = style == .two ? item.isSelected : item.isLabelSelected
            
            if selected {
                titleLabel.textColor = .wp.initWith(0, 146, 255, 1)
            }else{
                titleLabel.textColor = .wp.initWith(0, 0, 0, 0.85)
            }
            if style == .two {
//                stateImageView.isSelected = item.isSelected
                stateImageView.isHidden = !item.isSelected
            }else{
                stateImageView.isHidden = true
            }
        }
    }
}
