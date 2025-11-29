//
//  PictureEditOptionView.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import WPCommand
import Combine

extension PictureEditOptionView{
    enum Proportion:Equatable {
        case all(_ value:CGFloat)
        case p1_1(_ value:CGFloat)
        case p3_4(_ value:CGFloat)
        case p4_3(_ value:CGFloat)
        case p2_3(_ value:CGFloat)
        case p3_2(_ value:CGFloat)
        case p9_16(_ value:CGFloat)
        case p16_9(_ value:CGFloat)
        
       static func allCases(_ value:CGFloat) -> [Proportion] {
            return [
                .all(value),
                .p1_1(value),
                .p3_4(value),
                .p4_3(value),
                .p2_3(value),
                .p3_2(value),
                .p9_16(value),
                .p16_9(value)
            ]
        }

        func size() -> CGSize {
            switch self {
            case .all(let value):
                return .init(width: value / 3 * 4, height: value)
            case .p1_1(let value):
                return .init(width: value, height: value)
            case .p3_4(let value):
                return .init(width: value, height: value / 3 * 4)
            case .p4_3(let value):
                return .init(width: value / 3 * 4, height: value)
            case .p2_3(let value):
                return .init(width: value, height: value / 2 * 3)
            case .p3_2(let value):
                return .init(width: value / 2 * 3, height: value)
            case .p9_16(let value):
                return .init(width: value, height: value / 9 * 16)
            case .p16_9(let value):
                return .init(width: value / 9 * 16, height: value)
            }
        }

        var describe:String{
            switch self {
            case .all:
                return "all".localized()
            case .p1_1:
                 return "1:1"
            case .p3_4:
                 return "3:4"
            case .p4_3:
                 return "4:3"
            case .p2_3:
                 return "2:3"
            case .p3_2:
                 return "3:2"
            case .p9_16:
                 return "9:16"
            case .p16_9:
                 return "16:9"
            }
        }
        
        func copy(in value:CGFloat) -> Self{
            switch self {
            case .all:
                return .all(value)
            case .p1_1:
                return .p1_1(value)
            case .p3_4:
                return .p3_4(value)
            case .p4_3:
                return .p4_3(value)
            case .p2_3:
                return .p2_3(value)
            case .p3_2:
                return .p3_2(value)
            case .p9_16:
                return .p9_16(value)
            case .p16_9:
                return .p16_9(value)
            }
        }
    }

    /// 分割线的方向
    enum Direction {
        case horizontal
        case vertical
    }
}

extension PictureEditOptionView{
    static let barValueHeight = 30.0
    static let itemValueHeight = 48.0
}

class PictureEditOptionView: BaseView {

    let titleL = UILabel()
    let barView = UIStackView()
    let lineView = UIView()
    let allDirectionView = AllDirectionView()
    let directionView = DirectionView()

    /// bar 的方向
    @Published var barProportion = Proportion.all(barValueHeight)
    /// 选中比例
    @Published var currentProportion = Proportion.p1_1(itemValueHeight)
    /// 选中方向
    @Published var currentDirection = Direction.vertical

    override func bindViewModel() {
        $barProportion.sink(receiveValue: {[weak self] proportion in
            self?.barView.arrangedSubviews.forEach { view in
                (view as? ItemView)?.isSelected = false
            }
            let itemView = (self?.barView.arrangedSubviews as! [ItemView]).first(where: { $0.proportion == proportion })
            itemView?.isSelected = true
            
            switch proportion {
            case .all:
                self?.allDirectionView.isHidden = false
                self?.directionView.isHidden = true
            default:
                self?.directionView.isHidden = false
                self?.allDirectionView.isHidden = true
                self?.currentProportion = proportion.copy(in: PictureEditOptionView.itemValueHeight)
                self?.directionView.reset(proportion.copy(in: PictureEditOptionView.itemValueHeight))
            }

        }).store(in: &wp.cancellables.set)
        
        Publishers.CombineLatest($currentProportion, $currentDirection).sink(receiveValue: {[weak self] value in
            guard let self else { return }

            self.allDirectionView.allItemView().forEach { itemView in
                itemView.isSelected = false
            }
            
            self.allDirectionView.allItemView().first(where: { $0.proportion == value.0 && $0.direction == value.1 })?.isSelected = true
            
            
            switch value.1 {
            case .horizontal:
                self.directionView.horizontalItem.isSelected = true
                self.directionView.verticalItem.isSelected = false
            case .vertical:
                self.directionView.verticalItem.isSelected = true
                self.directionView.horizontalItem.isSelected = false
            }

        }).store(in: &wp.cancellables.set)
    }
    
    override func observeSubViewEvent() {
        var sources:[AnyPublisher<Proportion,Never>] = []

        Proportion.allCases(PictureEditOptionView.barValueHeight).forEach { proportion in
            let item = ItemView(proportion: proportion, direction: .horizontal, showText: true)
            let event = item.controlEventPublisher(for: .touchUpInside).map({ proportion}).eraseToAnyPublisher()
            sources.append(event)
            barView.addArrangedSubview(item)
        }
        
        Publishers.MergeMany(sources).sink(receiveValue: {[weak self] proportion in
            self?.barProportion = proportion
        }).store(in: &wp.cancellables.set)

        allDirectionView.click = {[weak self] proportion,direction in
            self?.currentDirection = direction
            self?.currentProportion = proportion
        }
        
        directionView.horizontalItem.controlEventPublisher(for: .touchUpInside).sink(receiveValue: {[weak self] in
            self?.currentDirection = .horizontal
        }).store(in: &wp.cancellables.set)
        
        directionView.verticalItem.controlEventPublisher(for: .touchUpInside).sink(receiveValue: { [weak self] in
            self?.currentDirection = .vertical
        }).store(in: &wp.cancellables.set)
    }

    override func initSubView() {
        
        titleL.text = "collage".localized()
        titleL.font = 16.font(.Symbol)
        titleL.textColor = .white
        barView.distribution = .equalSpacing
        barView.alignment = .center
        lineView.backgroundColor = .white.withAlphaComponent(0.7)

        backgroundColor = .wp.random
        addSubview(titleL)
        addSubview(barView)
        addSubview(allDirectionView)
        addSubview(directionView)
        addSubview(lineView)
    }
    
    override func initSubViewLayout() {
        titleL.snp.makeConstraints { make in
            make.top.left.equalTo(16)
        }
        
        barView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleL.snp.bottom).offset(8)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(barView.snp.bottom).offset(8)
            make.height.equalTo(0.5)
        }
        
        allDirectionView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(16)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        directionView.snp.makeConstraints { make in
            make.edges.equalTo(allDirectionView)
        }
    }

}

extension PictureEditOptionView{
    class AllDirectionView: BaseView {
        
        var click:((Proportion,Direction)->Void)?

        lazy var mainStack = WPStackScrollView(views: [],maxWidth: WPSystem.screen.maxWidth - 32)
        
        func allItemView() -> [ItemView] {
            return (mainStack.stackView.arrangedSubviews as! [UIStackView]).flatMap({ $0.arrangedSubviews }) as! [ItemView]
        }


        override func bindViewModel() {
            var allProportion = Proportion.allCases(itemValueHeight)
            allProportion.removeAll(where: { $0 == .all(itemValueHeight)})
            let sources = allProportion.map({ [$0,$0]}).flatMap({ $0})
            var count = 0
            var direction = PictureEditOptionView.Direction.horizontal
            var stackView = UIStackView()
            stackView.spacing = 20
            stackView.alignment = .center
            
            sources.forEach { elmt in
                count += 1
                if direction == .horizontal{
                    direction = .vertical
                }else if direction == .vertical{
                    direction = .horizontal
                }
                let itemView = ItemView(proportion: elmt, direction: direction, showText: false)
                stackView.addArrangedSubview(itemView)
                
                itemView.controlEventPublisher(for: .touchUpInside).sink(receiveValue: {[weak self] in
                    self?.click?(elmt,itemView.direction)
                }).store(in: &itemView.wp.cancellables.set)
                
                if count % 5 == 0{
                    mainStack.stackView.addArrangedSubview(stackView)
                    stackView = UIStackView()
                    stackView.spacing = 20
                    stackView.alignment = .center
                }
            }
            
            if !stackView.arrangedSubviews.isEmpty{
                mainStack.stackView.addArrangedSubview(stackView)
            }
        }

        override func initSubView() {
            mainStack.stackView.alignment = .leading
            mainStack.stackView.spacing = 20
            mainStack.stackView.axis = .vertical
            addSubview(mainStack)
        }
        
        override func initSubViewLayout() {
            mainStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension PictureEditOptionView{
    class DirectionView: BaseView {
        let verticalItem = ItemView(proportion: .all(itemValueHeight), direction: .vertical, showText: false)
        let horizontalItem = ItemView(proportion: .all(itemValueHeight), direction: .horizontal, showText: false)
        
        lazy var stackView = UIStackView(arrangedSubviews: [verticalItem,horizontalItem])
        
        func reset(_ proportion:Proportion){
            horizontalItem.reset(proportion)
            verticalItem.reset(proportion)
        }

        override func initSubView() {
            stackView.spacing =  24
            stackView.alignment = .center
            addSubview(stackView)
        }
        
        override func initSubViewLayout() {
            stackView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
            }
        }
    }
}


extension PictureEditOptionView{
    class ItemView:UIControl {
        
        let label = UILabel()
        let lineView = UIView()

        var proportion:Proportion
        let direction:Direction
        let showText:Bool
        
        override var isSelected: Bool{
            didSet{
                if isSelected {
                    layer.borderColor = UIColor.blue.cgColor
                    label.textColor = .black
                    lineView.backgroundColor = .blue
                }else{
                    layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
                    label.textColor = .white.withAlphaComponent(0.7)
                    lineView.backgroundColor = .white.withAlphaComponent(0.7)
                }
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            sendActions(for: .touchUpInside)
        }
        
        /// 重置比例
        func reset(_ proportion:Proportion){
            self.proportion = proportion
            snp.updateConstraints { make in
                make.size.equalTo(proportion.size())
            }
        }

        init(proportion: Proportion,
             direction: Direction,
             showText:Bool) {
            self.proportion = proportion
            self.direction = direction
            self.showText = showText
            label.text = proportion.describe
            label.font = 11.font(.AmericanTypewriter)
            
            if showText {
                label.isHidden = false
                lineView.isHidden = true
            }else{
                label.isHidden = true
                lineView.isHidden = false
            }
            super.init(frame: .zero)

            addSubview(label)
            addSubview(lineView)
            
            layer.cornerRadius = 6
            clipsToBounds = true
            layer.borderWidth = 1
            
            isSelected = false
            
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            lineView.snp.makeConstraints { make in
                switch direction{
                  case .horizontal:
                    make.centerY.equalToSuperview()
                    make.left.right.equalToSuperview()
                    make.height.equalTo(1)
                case .vertical:
                    make.centerX.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(1)
                }
            }

           reset(proportion)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
