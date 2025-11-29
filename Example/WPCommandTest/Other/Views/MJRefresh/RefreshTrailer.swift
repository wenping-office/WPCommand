//
//  RefreshTrailer.swift
//  WPCommand_Example
//
//  Created by kuaiyin on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MJRefresh

class RefreshTrailer: MJRefreshStateTrailer {
    
    var loadingView = UIActivityIndicatorView()
    
    private var stateImages: [MJRefreshState: UIImage] = [:]
    
    @discardableResult
    func setImage(_ image: UIImage?, for state: MJRefreshState) -> Self {
        guard let image = image else { return self }
        
        stateImages[state] = image
        
        if image.size.height > mj_h {
            mj_h = image.size.height
        }
        return self
    }
    
    private var currentHeight: CGFloat = 60 {
        didSet {
            mj_h = currentHeight
            // 触发父视图重新布局
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        setTitle("", for: .idle)
        setTitle("", for: .refreshing)
        setTitle("", for: .pulling)
        setTitle("", for: .noMoreData)
    }
    
    // MARK: - 状态切换动画
    override var state: MJRefreshState {
        didSet {
            guard oldValue != state else { return }
            
            switch state {
            case .refreshing:
                loadingView.isHidden = false
                loadingView.startAnimating()

            case .idle, .noMoreData:
                loadingView.stopAnimating()
                loadingView.isHidden = true
                loadingView.isHidden = (state == .noMoreData)
            case .pulling:
                loadingView.isHidden = false
                loadingView.startAnimating()
            default:
                loadingView.startAnimating()
                loadingView.isHidden = false
                break
            }
        }
    }
    
    func updateHeight(_ height: CGFloat, animated: Bool = true) {
        guard height != currentHeight else { return }
        
        currentHeight = height
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.superview?.layoutIfNeeded()
            }
        } else {
            self.superview?.layoutIfNeeded()
        }
    }
    
    override func endRefreshing() async {
        DispatchQueue.main.async(execute: {
            self.state = .idle
        })
    }
    
}

