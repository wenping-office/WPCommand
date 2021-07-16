//
//  WPTableView.swift
//  WPTableView
//
//  Created by WenPing on 2021/5/29.
//

import UIKit

open class WPTableView: WPTableAutoLayoutView {
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return groups[indexPath.section].items[indexPath.row].cellHeight
    }
}
