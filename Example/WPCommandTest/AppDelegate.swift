//
//  AppDelegate.swift
//  WPCommand
//
//  Created by Developer on 07/16/2021.
//  Copyright (c) 2021 Developer. All rights reserved.
//

import UIKit
import WPCommand
import SQLiteData

//pod trunk register wenping.office@foxmail.com 'wenping-office' --description='iMac' --verbose
//pod trunk push WPCommand.podspec --allow-warnings

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
//        IQKeyboardManager.shared.enable = true

        return true
    }
}

fileprivate enum DatabaseConstants {
    public static let rootPath: URL = .init(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "")!
    public static let databaseFolder: URL = rootPath.appendingPathComponent("database")
}

fileprivate func initDatabase(){
    prepareDependencies {
        do {
            $0.defaultDatabase = try appDatabase()
        } catch {
            fatalError("Failed to create database queue: \(error)")
        }
    }
}


fileprivate func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    #if DEBUG
        configuration.prepareDatabase { db in
            db.trace(options: .profile) {
                if context == .preview {
                    print("\($0.expandedDescription)")
                } else {
                    Log.info("\($0.expandedDescription)")
                }
            }
        }
    #endif
    let fileManager = FileManager.default

    // 创建目录
    try? fileManager.createDirectory(atPath: DatabaseConstants.databaseFolder.path,
                                     withIntermediateDirectories: false,
                                     attributes: nil)
    let database: any DatabaseWriter
    if context == .live {
        let path = DatabaseConstants.databaseFolder.appendingPathComponent("db.sqlite", isDirectory: false).path
        print("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    } else if context == .test {
        let path = DatabaseConstants.databaseFolder.appendingPathComponent("\(UUID().uuidString)-db.sqlite", isDirectory: false).path
        database = try DatabasePool(path: path, configuration: configuration)
    } else {
        database = try DatabaseQueue(configuration: configuration)
    }
    var migrator = DatabaseMigrator()
    #if DEBUG
        // 有点危险 先注释掉
//        migrator.eraseDatabaseOnSchemaChange = true
    #endif
    migrator.registerMigration("Create Task Table") { db in
        try db.create(table: "CreateTaskItems") { t in
            t.primaryKey("id", .text) // 唯一标识
            t.column("localImageName", .text) // 本地图片文件名
            t.column("isDemoImage", .boolean)
            t.column("remoteImagePath", .text) // 远端图片路径
            t.column("templateId", .text) // 模版ID
            t.column("taskId", .text) // 任务ID
            t.column("meadiaQuality", .integer) // 媒体质量
            t.column("status", .integer) // 状态
            t.column("dateCreated", .datetime)
            t.column("isRead", .boolean) // 是否已读
            t.column("generateType", .integer).notNull().defaults(to: 1)
            t.column("descText", .text)
            t.column("secondIsDemoImage", .boolean).defaults(to: true)
            t.column("secondLocalImageName", .text)
            t.column("secondRemoteImagePath", .text)
            t.column("workId", .integer)
        }
    }
    
    try migrator.migrate(database)
    return database
}
