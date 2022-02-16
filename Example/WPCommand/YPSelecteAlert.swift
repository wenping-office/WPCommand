//
//  YPSelecteAlert.swift
//  WPCommand_Example
//
//  Created by WenPing on 2022/2/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand

extension YPSelecteAlert{
    enum ShowType {
        /// 日期类型
        case date(type:YPDateStyle,normalDate:Date)
        case custom
    }
}

protocol YPSelecteAlertItem {
    
    /// 自定义视图
    /// - Returns: view
    func customItem(viewForRow row: Int, forComponent component: Int) -> UIView
}

extension YPSelecteAlertItem{
    func customItem(viewForRow row: Int, forComponent component: Int) -> UIView{
        let lab = UILabel(frame: .init(x: 0, y: 0, width: 150, height: 40))
        lab.text = "测试代码"
        lab.textAlignment = .center
        return lab
    }
}

class YPSelecteAlert: WPBaseView,WPAlertProtocol{
    /// 顶部筛选条
    let topBar = YPAlertTopBar()
    /// 日期筛选视图
    private(set) var datePickerView : YPDateView!
    /// 自定义pickerView
    let customPickerView = UIPickerView()
    /// 横条
    let horizontalView = UIView()
    /// 显示类型
    let showType : ShowType
    /// 日期选中回调
    var dateSelectedCallBack : ((Date)->Void)?
    /// 自定义选中回调
    var customSelectedCallBack : (([Any])->Void)?
    /// 自定义的数据源
    var customSource : [[YPSelecteAlertItem]] = []

    init(showType:ShowType) {
        switch showType {
        case .date(let type,let normalDate):
            datePickerView = YPDateView.init(dateStyle: type, forScroll: normalDate)!
            customPickerView.isHidden = true
        case .custom:
            datePickerView = YPDateView.init(dateStyle: .yearMonthDay, forScroll: Date())!
            datePickerView.isHidden = true
        }
        self.showType = showType
        super.init(frame: .zero)
    }

    override func initSubView() {
        backgroundColor = .white
        horizontalView.backgroundColor = UIColor.wp.initWith(245, 246, 250, 1)
        horizontalView.layer.cornerRadius = 4

        customPickerView.dataSource = self
        customPickerView.delegate = self

        datePickerView.dateLabelColor = .clear

        addSubview(horizontalView)
        addSubview(topBar)
        addSubview(customPickerView)
        addSubview(datePickerView)
    }

    override func initSubViewLayout() {
        topBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
//            make.width.equalTo(UIScreen.main.bounds.width)
        }

        datePickerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(327)
            make.bottom.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
        }

        customPickerView.snp.makeConstraints { make in
            make.edges.equalTo(datePickerView)
        }

        horizontalView.snp.makeConstraints { make in
            make.centerY.equalTo(datePickerView)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
    }

    override func observeSubViewEvent() {
        topBar.cancelBtn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] in
            self?.wp.dismiss()
        }).disposed(by: wp.disposeBag)

        topBar.qureBtn.rx.controlEvent(.touchUpInside).bind { [weak self] in
            guard
                let self = self
            else { return }

            switch self.showType {
            case .date( _, _):
                self.dateSelectedCallBack?(self.datePickerView.selectDate)
                break
            case .custom:
                self.customSelectedCallBack?(self.customSelectedData())
                break
            }

        }.disposed(by: wp.disposeBag)
    }

    private func customSelectedData() -> [Any] {
        var resualtArray : [Any] = []
        for component in 0..<customSource.count {
            let row = customPickerView.selectedRow(inComponent: component)
            resualtArray.append(customSource[component][row])
        }
        return resualtArray
    }

    func alertInfo() -> WPAlertManager.Alert {
        return .init(.default,
                     location: .bottomToFill(0),
                     showDuration: 0.3,
                     direction: .bottom,
                     dismissDuration: 0.3)
    }

    /// 显示日期
    /// - Parameters:
    ///   - style: 日期样式
    ///   - normalDate: 默认选中日期
    ///   - config: 配置
    ///   - view?: 显示到哪个view上
    static func showDate(in view:UIView?,
                         style:YPDateStyle,
                         normalDate:Date,
                         config:(YPSelecteAlert)->Void){
        let alert = YPSelecteAlert(showType: .date(type: style, normalDate: normalDate))
        config(alert)
        alert.wp.show(in:view)
    }

    static func showCustom(in view:UIView?,
                           source:[[YPSelecteAlertItem]],
                           config:(YPSelecteAlert)->Void,
                           callBack:([Any])->Void){
        let alert = YPSelecteAlert(showType: .custom)
        alert.customSource = source
        config(alert)
        alert.wp.show(in:view)
    }

}

extension YPSelecteAlert:UIPickerViewDelegate,UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return customSource.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customSource[component].count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        pickerView.subviews.wp_get(of: 1)?.isHidden = true
        pickerView.subviews.wp_get(of: 2)?.isHidden = true

        let elmt = customSource[component][row]
        
        return elmt.customItem(viewForRow: row, forComponent: component)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}
