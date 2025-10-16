//
//  WPRunTime.swift
//  WPCommand
//
//  Created by WenPing on 2021/8/9.
//

import UIKit

open class WPRunTime: NSObject {
    /// 返回指针指向的对象
    public static func get<T>(_ target: Any, _ key: UnsafeRawPointer) -> T? {
        return objc_getAssociatedObject(target, key) as? T
    }

    /// 动态添加一个属性
    public static func set(_ target: Any, _ value: Any?, _ key: UnsafeRawPointer, _ policy: objc_AssociationPolicy) {
        objc_setAssociatedObject(target, key, value, policy)
    }
}

open class WPGCD: NSObject {
    /// 主线程异步
    public static func main_Async(task: @escaping () -> Void) {
        DispatchQueue.main.async {
            task()
        }
    }

    /// 主线程同步
    public static func main_Sync(task: @escaping () -> Void) {
        DispatchQueue.main.sync {
            task()
        }
    }

    /// 主线程异步延迟
    public static func main_asyncAfter(_ timer: DispatchTime, task: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: timer) {
            task()
        }
    }
}

public enum WPAsync {
    public typealias Task = () -> Void

    /// 异步执行
    /// - Parameter task: 任务
    public static func async(_ task: @escaping Task) {
        _async(task)
    }

    /// 异步执行
    /// - Parameters:
    ///   - task: 异步任务
    ///   - mainTask: 主线程任务
    public static func async(_ task: @escaping Task,
                             _ mainTask: @escaping Task)
    {
        _async(task, mainTask)
    }

    private static func _async(_ task: @escaping Task,
                               _ mainTask: Task? = nil)
    {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().async(execute: item)
        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }

    /// 延迟执行
    /// - Parameters:
    ///   - seconds: 延迟时间
    ///   - task: 任务
    /// - Returns: 任务item
    @discardableResult
    public static func asyncDelay(_ seconds: Double,
                                  _ task: @escaping Task) -> DispatchWorkItem
    {
        return _asyncDelay(seconds, task)
    }

    /// 延迟异步执行
    /// - Parameters:
    ///   - seconds: 时间
    ///   - task: 异步任务
    ///   - mainTask: 主线程任务
    /// - Returns: 任务item
    @discardableResult
    public static func asyncDelay(_ seconds: Double,
                                  _ task: @escaping Task,
                                  _ mainTask: @escaping Task) -> DispatchWorkItem
    {
        return _asyncDelay(seconds, task, mainTask)
    }

    @discardableResult
    private static func _asyncDelay(_ seconds: Double,
                                    _ task: @escaping Task,
                                    _ mainTask: Task? = nil) -> DispatchWorkItem
    {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
        return item
    }
}

