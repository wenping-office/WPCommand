//
//  BaseVC.swift
//  ShoppingCommon
//
//  Created by Wen on 2023/8/22.
//

import WPCommand
import RxSwift
import RxCocoa

open class BaseVC: WPBaseVC {

    deinit {
        print(self.self,"---WP销毁")
    }

    open override var navigationisHidden: Bool{
        return true
    }
    
    public let navView = NavView()
    
    public lazy var bottomView: BottomView = {[weak self] in
        let view = BottomView()
        self?.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        return view
    }()

    //状态条(电池栏)颜色
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = .zero
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if title != nil{
            navView.titleView.text = title
            navView.leftTitleLabel.text = title
        }
    }
    
    open override func initSubView() {
        view.addSubview(navView)
        navView.backBtn.rx.controlEvent(.touchUpInside).bind(onNext: {[weak self] _ in
            self?.popoViewController()
        }).disposed(by: wp.disposeBag)
    }
    
    open override func initSubViewLayout() {
        navView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(WPSystem.screen.navigationHeight)

        }
    }
    
    open func addBackLeftView(){
        let view = UIView()
        self.view.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(WPSystem.screen.navigationHeight)
            make.width.equalTo(25)
        }
    }
    
    open func showNavToast(_ str:String?){
        let label = UILabel()
        view.addSubview(label)
        label.backgroundColor = .red
        label.text = str
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        
        label.snp.makeConstraints { make in
            make.left.right.equalTo(navView)
            make.top.equalTo(navView.snp.bottom).offset(-40)
            make.height.equalTo(40)
        }
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, animations: {
            label.alpha = 1
            label.snp.updateConstraints { make in
                make.top.equalTo(self.navView.snp.bottom).offset(0)
            }
            label.superview?.layoutIfNeeded()
        },completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    label.alpha = 0
                },completion: { _ in
                    label.removeFromSuperview()
                })
            })
        })
    }
}


public extension BaseVC{
    class NavView: BaseView {

        public let titleView = UILabel().wp.isHidden(true).value()
        
        public lazy var centerView = UIStackView.wp.views([titleView]).alignment(.center).spacing(8).value()
        
        public let backBtn = UIButton().wp.title("返回").font(.systemFont(ofSize: 12)).titleColor(.black).value()
        
        public let leftTitleLabel = UILabel().wp.font(.boldSystemFont(ofSize: 18)).textColor(.white).value()
        
        public lazy var leftView = UIStackView.wp.views([
            backBtn,
            leftTitleLabel
        ]).spacing(8).alignment(.center).value()
        
        public let rightView = UIStackView()
        
        public let lineView = UIView().wp.isHidden(true).do { view in
            view.backgroundColor = .separator
        }.value()
        
        public let backgroundImageView = UIImageView()

        /// 滑动透明监听接口
        public let offsetY = BehaviorRelay<CGFloat>.init(value: 0)

        public var maxScrollToAlphaValue:CGFloat = 300

        public override func observeSubViewEvent() {
            offsetY.bind(onNext: {[weak self] value in
                self?.backgroundImageView.alpha = value / (self?.maxScrollToAlphaValue ?? 0)
            }).disposed(by: wp.disposeBag)
        }

        override public func initSubView() {

             addSubview(backgroundImageView)
             addSubview(centerView)
            addSubview(leftView)
            addSubview(rightView)
            addSubview(lineView)
            backBtn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            leftTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        override public func initSubViewLayout() {
            backgroundImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            centerView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(leftView)
                make.width.lessThanOrEqualTo(UIScreen.main.bounds.width * 0.7)
            }
            
            leftView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-10)
                make.height.greaterThanOrEqualTo(24)
                make.right.lessThanOrEqualTo(rightView.snp.left).offset(-5)
            }
            
            rightView.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalTo(leftView)
            }
            
            lineView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
    }
}

public extension BaseVC{
    class BottomView: BaseView {
        public let contentView = UIStackView().wp.spacing(12).value()

        override public func initSubView() {
            super.initSubView()

            backgroundColor = .wp.initWith(35, 35, 43, 1)
            addSubview(contentView)
        }

        override public func initSubViewLayout() {
            super.initSubViewLayout()
            contentView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.bottom.equalToSuperview().offset(-(WPSystem.screen.safeArea.bottom + 20))
                make.height.greaterThanOrEqualTo(50)
                make.top.equalToSuperview().offset(20)
            }
        }

        public func setLeftMargin(_ margin: CGFloat) {
            contentView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(margin)
            }
        }

        public func setRightMargin(_ margin: CGFloat) {
            contentView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(-margin)
            }
        }
    }

}
