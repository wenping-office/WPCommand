import UIKit
import WPCommand

func money(count:Int)->CGFloat{
    let lx = 13.83
    let bj = 2916.10
    var money : CGFloat = 0
    for i in 1..<count {
        money += bj + lx *  CGFloat(i)
        print(money)
    }
    return money
}

let totalMoney = money(count: 120)
let surplusMoney = money(count: 78)

print("总金额:\(totalMoney)\n剩余还款:\(surplusMoney)\n已经还款:\(totalMoney-surplusMoney)")



var sum = 0.0
let 利息 = 13.83
let 本金 = 2916.10
/// 每个月利息
var a = 利息 + 本金

for i in 1..<120{
    sum = sum + a
    a = a + 利息
}

print(sum)

//第一个月 = 本金 + 利息
//第二个月 = 本金 + 利息 + 利息
//第三个月 = 本金 + 利息 + 利息 + 利息
//第四个月 = 本金 + 利息 + 利息 + 利息 + 利息
