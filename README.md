# WPCommand
通用库


弹窗协议都是可选实现,实现协议后由WPAlertManager弹出、可使用WPAlertManager动态修改alert高度或者offset，可搭配WPSystem.KeyBoard适配键盘
1、WPAlertProtocol 支持弹出一组弹窗 有序或无序弹出 支持Autolayout自适布局 或者frame布局 如是frame布局初始化.init(frame)需要填值

class Alert: UIView, WPAlertProtocol{
        /// 弹窗的属性
    func alertInfo()->WPAlertManager.Alert
        /// 点击了蒙层
    func touchMask()
        /// 弹窗状态变化后执行
    func stateDidUpdate(state: WPAlertManager.State){}
}

继承协议后调用show()及可显示 dismiss及销毁 或自定义显示逻辑
Alert.wp.show()

2、WPMenuView 支持多层嵌套展示 可自定义导航烂 自定义header控件 类似腾讯新闻骨架UI、嵌套情况下左右滑动手势适配
    
    // 创建一个PagingView
    let menuView = WPMenuView(navigationHeight: 44)
    // 设置子页面数据源 可支持添加header展示
    menuView.dataSource = self
    menuView.delegate = self
    menuView.selected(0)
    // 设置子页面个数
    menuView.setNavigation(itemVo.items)
    // 设置导航栏item间距
    menuView.navigationInset = .init(left: 30, right: 30, spacing: 30)
    
    // 如果子页面是tableView 那么可设置多手势识别
    menuView.multiGesture = true
    menuView.horizontalGestureAdaptation = true
    
    且在 WPMenuBodyViewProtocol 下的tableView滚动时实现 targetViewDidScroll接口即可适配上下拉手势
    tableView.wp.delegate.didScroll = {[weak self] view in
        self?.targetViewDidScroll?(view)
    }


轻量级面包屑控件
WPLabelsItemView协议 任意UIView子类都可以实现
3、WPLabelsView<WPLabelsItemView>
    // 可获取最终控件的高度
    contentHeight

class labelsItemView:WPLabelsItemView{
    /// 子item视图的宽度
    func labelItemWidth(with data:Any) -> CGFloat
}

4、WPAutoLatticeView 
    /// 格子视图
    /// - Parameters:
    ///   - views: 视图
    ///   - col: 列
    ///   - itemHeight: item约束等级
    ///   - itemWidth: item约束等级
    init(views: [UIView], col: Int, itemHeight: EqualType? = nil,itemWidth: EqualType? = nil)
// 支持自适应大小 内部使用AutoLayout布局 


5、UITableView && UICollectView 数据源代理扩展
let view = UITableView()
/// 快速创建tableView || 创建 UICollectView

let group = WPTableGropu()
let item = WPTableItem(cellClass:UITableViewCell.self)
group.items = [item]

WPTableGroup && WPTableItem 支持继承、可自定义各种复杂业务逻辑

// 设置数据源
view.wp.dataSource.groups = [group]


6、语法糖
使用语法糖之前
let view = UIView()
view.backgroundColor = .black
view.layer.cornerRadius = 20
view.clipsToBounds = true
view.isUserInteractionEnabled = false

使用语法糖后
 UIView().wp
    .backgroundColor(.black)
    .cornerRadius(20)
    .clipsToBounds(true)
    .isUserInteractionEnabled(false)
    .value()
                    
 UIButton().wp
   .title("***", .normal)
   .title("123", .selected)
   .image(UIImage(named: ""), .normal)
   .image(UIImage(named: "aa"), .selected)
   .isSelected(true)
   .value()
                    
"富文本".wp
    .attributed
    .font(.systemFont(ofSize: 30))
    .foregroundColor(.black)
    .append("123")
    .append("123".wp.attributed.font(.systemFont(ofSize: 18)))
    .value()

7、WPSystem app生命周期、键盘事件、设备类型、设备方向等接口封装
/// app生命周期相关接口
WPSystem.applocation.willShow ...
/// 键盘高度变化通知
WPSystem.keyboard.height...
/// 设备方向接口 安全区域等接口
WPSystem.screen.custom.orientation
/// 当前手机设备型号等接口
WPSystem.device

8、其它自定义控件
WPBlockView 静态视图
DateView 日期选择
LinkView支持自适应大小可为富文本添加点击手势响应控件
PaddingVIew 可快速为UIView添加一个内边距的工具控件
StackScrollView 支持滚动的stackView
TextField 可限制输入类型的输入框
TextView 可限制输入类型的文本输入框
PagesView 自定义分页圆点控件 自适应大小
PopoverVC 选项弹出框
WPHighlightMaskProtocol 继承协议后UIView可获得引导式访问效果

9、Extension 各类常见日期处理、字符串处理、数组去重、排序、切片、递归查找等扩展工具方法
