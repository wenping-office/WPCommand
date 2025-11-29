//
//  JXSegmentedView+Extension.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/10/24.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
//import JXSegmentedView
//
//extension JXSegmentedView{
//    
//    static func `default`(defaultSelectedIndex:Int = 0,
//                          dataSource:JXSegmentedViewDataSource? = nil,
//                          delegate:JXSegmentedViewDelegate? = nil,
//                          listContainer:JXSegmentedViewListContainer? = nil) -> JXSegmentedView {
//
//       let segmentedView = JXSegmentedView()
//       segmentedView.dataSource = dataSource
//       segmentedView.delegate = delegate
//       segmentedView.listContainer = listContainer
//       let indicator = JXSegmentedIndicatorGradientLineView()
//       indicator.indicatorWidth = 20
//       indicator.indicatorHeight = 4
//       indicator.colors = [.C_FF7A87, .C_BA20E9]
//       indicator.verticalOffset = 8
//       segmentedView.indicators = [indicator]
//       segmentedView.defaultSelectedIndex = defaultSelectedIndex
//       return segmentedView
//    }
//    
//    static func roundedBorder(defaultSelectedIndex:Int = 0,
//                          dataSource:RoundedBorderDataSource? = nil,
//                          delegate:JXSegmentedViewDelegate? = nil,
//                          listContainer:JXSegmentedViewListContainer? = nil) -> JXSegmentedView {
//
//       let segmentedView = JXSegmentedView()
//       segmentedView.dataSource = dataSource
//       segmentedView.delegate = delegate
//       segmentedView.listContainer = listContainer
//       segmentedView.defaultSelectedIndex = defaultSelectedIndex
//       return segmentedView
//    }
//
//}
//
//extension JXSegmentedTitleDataSource{
//    
//    static func `default`(_ titles:[String]) -> JXSegmentedTitleDataSource{
//        let dataSource = JXSegmentedTitleDataSource()
//        dataSource.titleNormalColor = .C_1A1A1A
//        dataSource.titleSelectedColor = .C_1A1A1A
//        dataSource.titleNormalFont = 16.font_regular()
//        dataSource.titleSelectedFont = 16.font_bold()
//        dataSource.isItemSpacingAverageEnabled = false
//        dataSource.titles = titles
//        return dataSource
//    }
//    
//    static func roundedBorder(_ titles:[String],
//                              normalImageNames:[String]? = nil,
//                              selectedImageNames:[String]? = nil,
//                              cornerRadius:CGFloat = 8) -> RoundedBorderDataSource{
//        let dataSource = RoundedBorderDataSource()
//        dataSource.cornerRadius = cornerRadius
//        dataSource.itemSpacing = 8
//        dataSource.titleNormalColor = .C_1A1A1A
//        dataSource.titleSelectedColor = .C_1A1A1A
//        dataSource.titleNormalFont = 14.font_regular()
//        dataSource.titleSelectedFont = 14.font_bold()
//        dataSource.isItemSpacingAverageEnabled = false
//        dataSource.titles = titles
//        dataSource.normalImageInfos = normalImageNames
//        dataSource.selectedImageInfos = selectedImageNames
//        return dataSource
//    }
//}
//
//class RoundedBorderItemModel:JXSegmentedTitleImageItemModel{
//    var cornerRadius:CGFloat = 0
//}
//
//class RoundedBorderDataSource: JXSegmentedTitleImageDataSource {
//    
//    var cornerRadius:CGFloat = 0
//
//    override func registerCellClass(in segmentedView: JXSegmentedView) {
//        segmentedView.collectionView.register(RoundedBorderCell.self, forCellWithReuseIdentifier: "cell")
//    }
//    
//    override func preferredItemModelInstance() -> JXSegmentedBaseItemModel {
//        let model = RoundedBorderItemModel()
//        model.cornerRadius = cornerRadius
//        return model
//    }
//    
//    override func preferredSegmentedView(_ segmentedView: JXSegmentedView, widthForItemAt index: Int) -> CGFloat {
//        let title = self.titles[index]
//        let titleWidth = title.width(titleNormalFont)
//        
//        let imageName = self.normalImageInfos?[index] ?? ""
//
//        var spacing:CGFloat = 20
//        var imageWidth:CGFloat = 0
//        
//        if imageName.count > 0{
//            imageWidth = 16
//            spacing += 8
//        }
//
//        return titleWidth + imageWidth + spacing
//    }
//}
//
//class RoundedBorderCell: JXSegmentedBaseCell {
//    let titleLabel = UILabel()
//    let iconV = UIImageView()
//    lazy var stackView = UIStackView(arrangedSubviews: [iconV,titleLabel])
//
//    let selectedBgView = UIView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        backgroundColor = .C_E5E5E5
//        contentView.addSubview(selectedBgView)
//
//        stackView.alignment = .center
//        stackView.spacing = 4
//        
//        titleLabel.textAlignment = .center
//        contentView.addSubview(stackView)
//
//        iconV.snp.makeConstraints { make in
//            make.width.height.equalTo(16)
//        }
//        stackView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//        
//        selectedBgView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func reloadData(itemModel: JXSegmentedBaseItemModel, selectedType: JXSegmentedViewItemSelectedType) {
//        super.reloadData(itemModel: itemModel, selectedType: selectedType)
//        
//        guard let model = itemModel as? RoundedBorderItemModel else { return }
//        
//        titleLabel.text = model.title
//        iconV.isHidden = (model.normalImageInfo?.count ?? 0) <= 0
//        titleLabel.font = 14.font_regular()
//        
//        layer.cornerRadius = model.cornerRadius
//        layer.masksToBounds = true
//
//        selectedBgView.setGradientBorder(colors: [.C_FF7A87,.C_BA20E9], borderWidth: 1,cornerRadius: model.cornerRadius)
//        selectedBgView.setGradientBackground(colors: [.C_FFD5DB,.C_E78FFF],cornerRadius: model.cornerRadius)
//
//        if model.isSelected{
//            titleLabel.textColor = .C_B9066F
//            selectedBgView.isHidden = false
//            if model.selectedImageInfo != nil{
//                iconV.image = UIImage(named: model.selectedImageInfo!)
//            }
//        }else{
//            titleLabel.textColor = .C_1A1A1A
//            selectedBgView.isHidden = true
//           
//            if model.normalImageInfo != nil{
//                iconV.image = UIImage(named: model.normalImageInfo!)
//            }
//        }
//    }
//}
//
