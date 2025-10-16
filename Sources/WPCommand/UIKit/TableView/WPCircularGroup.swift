//
//  WPCircularGroup.swift
//  WPCommand
//
//  Created by Wen on 2024/1/11.
//

import UIKit

open class WPCircularGroup: WPTableGroup {
    
    /// 圆角
    var radius:CGFloat = 10

    open override var items: [WPTableItem]{
        set{
            newValue.forEach { item in
                (item as? WPCircularItem)?.isShowLine = true

                item.willDisplay = { cell in
                    if let cirCell = cell as? WPCircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight], radius: 0)
                    }
                }
            }
            
            if newValue.count == 1{
                newValue.first?.willDisplay = {[weak self] cell in
                    if let cirCell = cell as? WPCircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight,.bottomLeft,.bottomRight], radius: self?.radius ?? 0)
                    }
                }
            }else{
                newValue.first?.willDisplay = {[weak self] cell in
                    if let cirCell = cell as? WPCircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.topLeft,.topRight], radius: self?.radius ?? 0)
                    }
                }
                
                newValue.last?.willDisplay = {[weak self] cell in
                    if let cirCell = cell as? WPCircularCell{
                        cirCell.contentBackgroundView.layoutIfNeeded()
                        cirCell.contentBackgroundView.wp.corner([.bottomLeft,.bottomRight], radius: self?.radius ?? 0)
                    }
                }
            }
            (newValue.last as? WPCircularItem)?.isShowLine = false
        }
        get{
            return super.items
        }
    }

}
