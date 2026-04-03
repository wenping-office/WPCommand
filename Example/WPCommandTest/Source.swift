//
//  Source.swift
//  WPCommand
//
//  Created by tmb on 2026/4/3.
//

import UIKit


nonisolated enum SectionType:Sendable,Hashable,Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
    }
    
    static func == (lhs: DataType, rhs: DataType) -> Bool {
        return lhs.kind == rhs.kind
    }
    
    /// 电影
    case movie
}

extension SectionType {
    
    var kind:Kind{
        switch self {
        case .movie: return .movie
        }
    }
    
    enum Kind {
        case movie
    }
}

nonisolated enum ItemType:Sendable,Hashable,Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
    }
    
    static func == (lhs: DataType, rhs: DataType) -> Bool {
        return lhs.kind == rhs.kind
    }
    /// 电影
    case movie
}

extension ItemType{
    
    var kind:Kind{
        switch self {
        case .movie: return .movie
        }
    }
    
    enum Kind {
        case movie
    }
}

nonisolated struct Item<T: Sendable & Hashable>:Hashable,Equatable,Sendable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }

    let id = UUID()
    let data:T

    init(_ data: T) {
        self.data = data
    }
}

nonisolated struct Section<T: Sendable & Hashable>:Hashable,Equatable,Sendable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }

    let id = UUID()
    let data:T

    init(_ data: T) {
        self.data = data
    }
}


nonisolated struct ListSection:Hashable,Equatable {
    let id = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    let type: Section
    
    enum Section {
        case test
    }
    
    init(_ type: Section) {
        self.type = type
    }
}


nonisolated struct ListItem:Hashable,Equatable {
    let id = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ListSection, rhs: ListSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    let type: Section
    
    enum Section {
        case test
    }
    
    init(_ type: Section) {
        self.type = type
    }
}

