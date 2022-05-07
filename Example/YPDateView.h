//
//  YPDateView.h
//  meal
//
//  Created by WenPing on 2017/11/7.
//  Copyright © 2017年 Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  弹出日期类型
 */

typedef NS_ENUM(NSInteger, YPDateStyle){
    YPDateStyleYearMonthDayHourMinute  = 0,//年月日时分
    YPDateStyleYear,// 年
    YPDateStyleMonthDayHourMinute,//月日时分
    YPDateStyleMonthDayHour,// 月日时
    YPDateStyleYearMonthDayHour,// 年月日时
    YPDateStyleYearMonthDay,//年月日
    YPDateStyleYearMonth,// 年月
    YPDateStyleMonthDay,//月日
    YPDateStyleHourMinute,//时分
};

@class YPDateView;
typedef void(^selectBlock)(NSDate *date);

/**  */
@protocol YPDateViewDelegate<NSObject>
@optional
/** 即将返回一行时调用 返回行数 */
- (NSUInteger)dateView:(YPDateView *)dataView willSelectedRow:(NSInteger)row forComponent:(NSInteger)component;
/** 即将返回一组时调用 返回组数 */
- (NSUInteger)dateView:(YPDateView *)dataView willSelectedComponent:(NSInteger)component forRow:(NSInteger)row;

@end

@interface YPDateView : UIView
/** 初始化方法 */
- (instancetype)initWithDateStyle:(YPDateStyle)datePickerStyle forScrollDate:(NSDate *)date;
/**
 默认滚动到当前时间
 */
-(instancetype)initWithDateStyle:(YPDateStyle)datePickerStyle completeBlock:(selectBlock)selectBlcok;

/**
 滚动到指定的的日期
 */
-(instancetype)initWithDateStyle:(YPDateStyle)datePickerStyle scrollToDate:(NSDate *)scrollToDate completeBlock:(selectBlock)selectBlcok;

/**
 正在滚动日期
 */
-(instancetype)initWithDateStyle:(YPDateStyle)datePickerStyle didSelectBlock:(selectBlock)selectBlcok;
//日期存储数组
@property (nonatomic,strong) NSMutableArray *yearArray;
@property (nonatomic,strong) NSMutableArray *monthArray;
@property (nonatomic,strong) NSMutableArray *dayArray;
@property (nonatomic,strong) NSMutableArray *hourArray;
/** 分钟数 */
@property (nonatomic,strong) NSMutableArray *minuteArray;
/** 日期采集器 */
@property (nonatomic,strong)UIPickerView *datePicker;

@property (nonatomic,weak) id<YPDateViewDelegate> delegate;

/**
 *  当前选中的时间
 */
@property (nonatomic,strong) NSDate *selectDate;
/**
    选中的时间str
 */
@property (nonatomic,copy) NSString *dateStr;
/**
 *  年-月-日-时-分 文字颜色(默认橙色)
 */
@property (nonatomic,strong)UIColor *dateLabelColor;
/**
 *  滚轮日期颜色(默认黑色)
 */
@property (nonatomic,strong)UIColor *datePickerColor;

/**
 *  限制最大时间（默认2099）datePicker大于最大日期则滚动回最大限制日期
 */
@property (nonatomic, retain) NSDate *maxLimitDate;
/**
 *  限制最小时间（默认0） datePicker小于最小日期则滚动回最小限制日期
 */
@property (nonatomic, retain) NSDate *minLimitDate;

/**
 *  大号年份字体颜色(默认灰色)想隐藏可以设置为clearColor
 */
@property (nonatomic, retain) UIColor *yearLabelColor;


@end




@interface NSDate (Extension)
+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format;

@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;
- (NSDate *)dateWithFormatter:(NSString *)formatter;
- (NSString *)dateWithFormat:(NSString *)format;

@end


