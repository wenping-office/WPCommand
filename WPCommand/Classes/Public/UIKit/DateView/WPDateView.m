//
//  WPDateView.m
//  meal
//
//  Created by WenPing on 2017/11/7.
//  Copyright © 2017年 Developer. All rights reserved.
//

#import "WPDateView.h"

#define kPickerSize self.datePicker.frame.size
#define MAXYEAR 2099
#define MINYEAR 1970
#define LabelFont [UIFont systemFontOfSize:17]

@interface WPDateView ()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate> {
    
    NSString *_dateFormatter;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger preRow;
   NSInteger minuteIndex;
    NSDate *_startDate;
}
@property (weak, nonatomic)  WPDateContentLabelsView *showYearView;

@property (nonatomic, retain) NSDate *scrollToDate;//滚到指定日期
@property (nonatomic,strong)selectBlock selectBlock;
@property (nonatomic,strong) selectBlock didChangeBlock;

@property (nonatomic,assign)WPDateStyle datePickerStyle;
@property (nonatomic,assign)UIEdgeInsets labelPadding;

@end

@implementation WPDateView : UIView

- (instancetype)initWithDateStyle:(WPDateStyle)datePickerStyle labelPadding:(UIEdgeInsets)padding forScrollDate:(NSDate *)date
{
    if ([super init]) {
        self.labelPadding = padding;
        self.dateLabelColor =  [UIColor redColor];
        self.datePickerColor = [UIColor blackColor];
        
        if(date){
            _scrollToDate = date;
        }else{
            _scrollToDate = [NSDate new];
        }
        
        self.selectDate = _scrollToDate;

        UIPickerView *datePicker = [[UIPickerView alloc] init];
        datePicker.showsSelectionIndicator = YES;
        datePicker.delegate = self;
        datePicker.dataSource = self;
        datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _datePicker = datePicker;
        [self addSubview:datePicker];
        
        WPDateContentLabelsView *showYearView = [WPDateContentLabelsView new];
        showYearView.userInteractionEnabled = false;
        _showYearView = showYearView;
        [self addSubview:showYearView];

        self.datePickerStyle = datePickerStyle;
        switch (datePickerStyle) {
            case WPDateStyleYearMonthDayHourMinute:
                _dateFormatter = @"yyyy-MM-dd HH:mm";
                break;
            case WPDateStyleMonthDayHourMinute:
                _dateFormatter = @"yyyy-MM-dd HH:mm";
                break;
            case WPDateStyleYearMonthDay:
                _dateFormatter = @"yyyy-MM-dd";
                break;
            case WPDateStyleYearMonth:
                _dateFormatter = @"yyyy-MM-dd";
                break;
            case WPDateStyleMonthDay:
                _dateFormatter = @"yyyy-MM-dd";
                break;
            case WPDateStyleHourMinute:
                _dateFormatter = @"HH:mm";
                break;
            case WPDateStyleYearMonthDayHour:
                _dateFormatter = @"yyyy-MM-dd HH";
                break;
            case WPDateStyleMonthDayHour:
                _dateFormatter = @"MM-dd HH";
                break;
            default:
                _dateFormatter = @"yyyy-MM-dd HH:mm";
                break;
        }
        
        [self defaultConfig];
    }
    
    return self;
}

/**
 默认滚动到当前时间
 */
-(instancetype)initWithDateStyle:(WPDateStyle)datePickerStyle labelPadding:(UIEdgeInsets)padding completeBlock:(selectBlock)selectBlcok {
    self = [self initWithDateStyle:datePickerStyle labelPadding:padding forScrollDate:nil];
    self.selectBlock = selectBlcok;
    return self;
}

/**
 滚动到指定的的日期
 */
-(instancetype)initWithDateStyle:(WPDateStyle)datePickerStyle labelPadding:(UIEdgeInsets)padding scrollToDate:(NSDate *)scrollToDate completeBlock:(selectBlock)selectBlcok {
    self = [self initWithDateStyle:datePickerStyle labelPadding:padding forScrollDate:scrollToDate];
    self.selectBlock = selectBlcok;
    return self;
}

- (instancetype)initWithDateStyle:(WPDateStyle)datePickerStyle labelPadding:(UIEdgeInsets)padding didSelectBlock:(selectBlock)selectBlcok
{
    self = [self initWithDateStyle:datePickerStyle labelPadding:padding forScrollDate:nil];
    self.didChangeBlock = selectBlcok;
    return self;
}

-(void)defaultConfig {
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    //设置年月日时分数据
    _yearArray = [self setArray:_yearArray];
    _monthArray = [self setArray:_monthArray];
    _dayArray = [self setArray:_dayArray];
    _hourArray = [self setArray:_hourArray];
    _minuteArray = [self setArray:_minuteArray];
    
    for (int i=0; i<60; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (0<i && i<=12)
            [_monthArray addObject:num];
        if (i<24)
            [_hourArray addObject:num];
        [_minuteArray addObject:num];
    }
    for (NSInteger i=MINYEAR; i<=MAXYEAR; i++) {
        NSString *num = [NSString stringWithFormat:@"%ld",(long)i];
        [_yearArray addObject:num];
    }
    
    //最大最小限制
    if (!self.maxLimitDate) {
        self.maxLimitDate = [NSDate date:@"2099-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
    //最小限制
    if (!self.minLimitDate) {
        self.minLimitDate = [NSDate date:@"0000-01-01 00:00" WithFormat:@"yyyy-MM-dd HH:mm"];
    }
}

- (void)setSelectDate:(NSDate *)selectDate
{
    _selectDate = selectDate;

    self.dateStr = [selectDate dateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
}

-(void)addLabelWithName:(NSArray *)nameArr {
    for (id subView in self.showYearView.subviews) {
        if ([subView isKindOfClass:[WPDateLabel class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i=0; i<nameArr.count; i++) {
        WPDateLabel *label = [WPDateLabel new];
        label.label.text = nameArr[i];
        label.label.font = [UIFont systemFontOfSize:14];
        label.label.textColor =  _dateLabelColor;
        label.backgroundColor = [UIColor clearColor];
        
        if ([label.label.text isEqualToString:@"年"]){
            label.offset = 28 + 3;
        }else{
            label.offset = 17 + 3;
        }
        [self.showYearView addSubview:label];
    }
}

-(void)setDateLabelColor:(UIColor *)dateLabelColor {
    _dateLabelColor = dateLabelColor;
    for (id subView in self.showYearView.subviews) {
        if ([subView isKindOfClass:[WPDateLabel class]]) {
            WPDateLabel *label = subView;
            label.label.textColor = _dateLabelColor;
        }
    }
}

- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (self.datePickerStyle) {
        case WPDateStyleYearMonthDayHourMinute:
            [self addLabelWithName:@[@"年",@"月",@"日",@"时",@"分"]];
            return 5;
        case WPDateStyleMonthDayHourMinute:
            [self addLabelWithName:@[@"月",@"日",@"时",@"分"]];
            return 4;
        case WPDateStyleYearMonth:
            [self addLabelWithName:@[@"年",@"月"]];
            return 2;
        case WPDateStyleYearMonthDay:
            [self addLabelWithName:@[@"年",@"月",@"日"]];
            return 3;
        case WPDateStyleMonthDay:
            [self addLabelWithName:@[@"月",@"日"]];
            return 2;
        case WPDateStyleHourMinute:
            [self addLabelWithName:@[@"时",@"分"]];
            return 2;
        case WPDateStyleMonthDayHour:
            [self addLabelWithName:@[@"月",@"日",@"时"]];
            return 3;
        case WPDateStyleYearMonthDayHour:
            [self addLabelWithName:@[@"年",@"月",@"日",@"时"]];
            return 4;
            
        default:
            return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *numberArr = [self getNumberOfRowsInComponent];
    return [numberArr[component] integerValue];
}

-(NSArray *)getNumberOfRowsInComponent {
    
    NSInteger yearNum = _yearArray.count;
    NSInteger monthNum = _monthArray.count;
    NSInteger dayNum = [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
    NSInteger hourNum = _hourArray.count;
    NSInteger minuteNUm = _minuteArray.count;
    
    NSInteger timeInterval = MAXYEAR - MINYEAR;
    
    switch (self.datePickerStyle) {
        case WPDateStyleYearMonthDayHourMinute:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum),@(minuteNUm)];
            break;
        case WPDateStyleMonthDayHourMinute:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum),@(minuteNUm)];
            break;
        case WPDateStyleYearMonthDay:
            return @[@(yearNum),@(monthNum),@(dayNum)];
            break;
        case WPDateStyleYearMonth:
            return @[@(yearNum),@(monthNum)];
        case WPDateStyleMonthDay:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum)];
            break;
        case WPDateStyleHourMinute:
            return @[@(hourNum),@(minuteNUm)];
            break;
        case WPDateStyleMonthDayHour:
            return @[@(monthNum*timeInterval),@(dayNum),@(hourNum)];
            break;
        case WPDateStyleYearMonthDayHour:
            return @[@(yearNum),@(monthNum),@(dayNum),@(hourNum)];
            break;
        default:
            return @[];
            break;
    }
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:LabelFont];
    }
    NSString *title;

    switch (self.datePickerStyle) {
        case WPDateStyleYearMonthDayHourMinute:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            if (component==3) {
                title = _hourArray[row];
            }
            if (component==4) {
                title = _minuteArray[row];
            }
            break;
        case WPDateStyleYearMonth:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            break;
        case WPDateStyleYearMonthDay:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            break;
        case WPDateStyleMonthDayHourMinute:
            if (component==0) {
                title = _monthArray[row%12];
            }
            if (component==1) {
                title = _dayArray[row];
            }
            if (component==2) {
                title = _hourArray[row];
            }
            if (component==3) {
                if (row >= _minuteArray.count) {
                    title = _minuteArray.firstObject;
                }else{
                    title = _minuteArray[row];
                }
            }
            break;
        case WPDateStyleMonthDay:
            if (component==0) {
                title = _monthArray[row%12];
            }
            if (component==1) {
                title = _dayArray[row];
            }
            break;
        case WPDateStyleHourMinute:
            if (component==0) {
                title = _hourArray[row];
            }
            if (component==1) {
                title = _minuteArray[row];
            }
            break;
            
        case WPDateStyleMonthDayHour:
            if (component==0) {
                title = _monthArray[row%12];
            }
            if (component==1) {
                title = _dayArray[row];
            }
            if (component==2) {
                title = _hourArray[row];
            }
            break;
            
        case WPDateStyleYearMonthDayHour:
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            if (component==3) {
                title = _hourArray[row];
            }
            break;
            
        default:
            title = @"00";
            break;
    }
    
    customLabel.text = title;
    customLabel.textColor = _datePickerColor;
    return customLabel;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if ([self.delegate respondsToSelector:@selector(dateView:willSelectedComponent:forRow:)]) {
        component = [self.delegate dateView:self willSelectedComponent:component forRow:row];
    }
    
    if ([self.delegate respondsToSelector:@selector(dateView:willSelectedRow:forComponent:)]) {
        row = [self.delegate dateView:self willSelectedRow:row forComponent:component];
    }
    switch (self.datePickerStyle) {
        case WPDateStyleYearMonthDayHourMinute:{
            
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 3) {
                hourIndex = row;
            }
            if (component == 4) {
                minuteIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
                
            }
        }
            break;
        case WPDateStyleYearMonth:
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }

            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            }
            break;
        case WPDateStyleYearMonthDay:{
            
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
        }
            break;
            
        case WPDateStyleMonthDayHourMinute:{
            
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            if (component == 3) {
                minuteIndex = row;
            }
            
            if (component == 0) {
                
                [self yearChange:row];
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
            
        }
            break;
            
        case WPDateStyleMonthDay:{
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 0) {
                
                [self yearChange:row];
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
        }
            break;
            
        case WPDateStyleHourMinute:{
            if (component == 0) {
                hourIndex = row;
            }
            if (component == 1) {
                minuteIndex = row;
            }
        }
            break;
        case WPDateStyleYearMonthDayHour:{
            
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 3) {
                hourIndex = row;
            }

            if (component == 0 || component == 1){
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
                
            }
        }
            break;
            
        case WPDateStyleMonthDayHour:{

            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            
            
            if (component == 0) {

                [self yearChange:row];
                [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];
                if (_dayArray.count-1<dayIndex) {
                    dayIndex = _dayArray.count-1;
                }
            }
            [self DaysfromYear:[_yearArray[yearIndex] integerValue] andMonth:[_monthArray[monthIndex] integerValue]];

        }
            break;
        default:
            break;
    }
    
    [pickerView reloadAllComponents];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",_yearArray[yearIndex],_monthArray[monthIndex],_dayArray[dayIndex],_hourArray[hourIndex],_minuteArray[minuteIndex]];
    
    self.scrollToDate = [[NSDate date:dateStr WithFormat:@"yyyy-MM-dd HH:mm"] dateWithFormatter:_dateFormatter];
    
    if ([self.scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.minLimitDate animated:YES];
    }else if ([self.scrollToDate compare:self.maxLimitDate] == NSOrderedDescending){
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
    
    _startDate = self.scrollToDate;
    self.selectDate = self.scrollToDate;
    if (self.selectBlock) {
        self.selectBlock(self.scrollToDate);
    }
    
    if (self.didChangeBlock) {
        self.didChangeBlock(self.scrollToDate);
    }
}

-(void)yearChange:(NSInteger)row {
    
    monthIndex = row%12;
    
    //年份状态变化
    if (row-preRow <12 && row-preRow>0 && [_monthArray[monthIndex] integerValue] < [_monthArray[preRow%12] integerValue]) {
        yearIndex ++;
    } else if(preRow-row <12 && preRow-row > 0 && [_monthArray[monthIndex] integerValue] > [_monthArray[preRow%12] integerValue]) {
        yearIndex --;
    }else {
        NSInteger interval = (row-preRow)/12;
        yearIndex += interval;
    }
    
    preRow = row;
}

#pragma mark - tools
//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) {
        date = [NSDate date];
    }
    
    [self DaysfromYear:date.year andMonth:date.month];
    
    yearIndex = date.year-MINYEAR;
    monthIndex = date.month-1;
    dayIndex = date.day-1;
    hourIndex = date.hour;
    minuteIndex = date.minute;
    
    //循环滚动时需要用到
    preRow = (self.scrollToDate.year-MINYEAR)*12+self.scrollToDate.month-1;
    
    NSArray *indexArray;
    
    if (self.datePickerStyle == WPDateStyleYearMonthDayHourMinute)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == WPDateStyleYearMonth)
        indexArray = @[@(yearIndex),@(monthIndex)];
    if (self.datePickerStyle == WPDateStyleYearMonthDay)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == WPDateStyleMonthDayHourMinute)
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == WPDateStyleMonthDay)
        indexArray = @[@(monthIndex),@(dayIndex)];
    if (self.datePickerStyle == WPDateStyleHourMinute)
        indexArray = @[@(hourIndex),@(minuteIndex)];
    if (self.datePickerStyle == WPDateStyleYearMonthDayHour)
        indexArray = @[@(yearIndex),@(monthIndex),@(dayIndex),@(hourIndex)];
    if (self.datePickerStyle == WPDateStyleMonthDayHour)
        indexArray = @[@(monthIndex),@(dayIndex),@(hourIndex)];
    
    [self.datePicker reloadAllComponents];
    
    for (int i=0; i<indexArray.count; i++) {
        if ((self.datePickerStyle == WPDateStyleMonthDayHourMinute || self.datePickerStyle == WPDateStyleMonthDay || self.datePickerStyle == WPDateStyleMonthDayHour)&& i==0) {
            NSInteger mIndex = [indexArray[i] integerValue]+(12*(self.scrollToDate.year - MINYEAR));
            [self.datePicker selectRow:mIndex inComponent:i animated:animated];
        } else {
            [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
        }
        
    }
}

#pragma mark - getter / setter
-(void)setMinLimitDate:(NSDate *)minLimitDate {

    _minLimitDate = minLimitDate;
    if ([_scrollToDate compare:self.minLimitDate] == NSOrderedAscending) {
        _scrollToDate = self.minLimitDate;
    }
    [self getNowDate:self.scrollToDate animated:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.datePicker.frame = self.bounds;
    self.showYearView.frame = CGRectMake(self.labelPadding.left, 0, self.frame.size.width-self.labelPadding.left-self.labelPadding.right, 40);
    self.showYearView.center = self.datePicker.center;

}
@end


static const unsigned componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (Extension)

+ (NSDate *)date:(NSString *)datestr WithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:datestr];
#if ! __has_feature(objc_arc)
    [dateFormatter release];
#endif
    return date;
}

-(NSDate *)dateWithFormatter:(NSString *)formatter {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = formatter;
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:self];
    return date;
}

- (NSInteger) hour
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.hour;
}

- (NSInteger) minute
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.minute;
}

- (NSInteger) seconds
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.second;
}

- (NSInteger) day
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.day;
}

- (NSInteger) month
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.month;
}

- (NSInteger) week
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfMonth;
}

- (NSInteger) weekday
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger) year
{
    NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
    return components.year;
}

+ (NSCalendar *) currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}
@end

@implementation WPDateContentLabelsView


- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat pad = 5;
    CGFloat width = (self.frame.size.width - pad * (self.subviews.count - 1)) / self.subviews.count;

    for (int i = 0; i<self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        view.frame = CGRectMake(i*width + pad * i, 0, width, self.frame.size.height);
    }
}


@end


@implementation WPDateLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        UILabel *label = [UILabel new];
        _label = label;
        [self addSubview:label];
    }
    return self;
}

- (void)setOffset:(CGFloat)offset{
    _offset = offset;
    
    [self layoutSubviews];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.label sizeToFit];
    self.label.frame = CGRectMake((self.frame.size.width - self.label.frame.size.width) *0.5 + self.offset, (self.frame.size.height-self.label.frame.size.height) * 0.5, self.label.frame.size.width, self.label.frame.size.height);
    
    self.label.center = CGPointMake((self.frame.size.width * 0.5) + self.offset, self.frame.size.height * 0.5);
}


@end

