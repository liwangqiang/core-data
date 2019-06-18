//
//  MoodSource.swift
//  Moody
//
//  Created by Florian on 27/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData

enum MoodSource {
    case country(Country)
    case continent(Continent)
}

// Helper 方法. 包装 Region.
// 原因是 Region 和 Country / Continent 没有关系. 这些方法若定义在 Region 上也没有办法用一个 Country 初始化 Region
extension MoodSource {
    init(region: NSManagedObject) {
        if let country = region as? Country {
            self = .country(country)
        } else if let continent = region as? Continent {
            self = .continent(continent)
        } else {
            fatalError("\(region) is not a valid mood source")
        }
    }

    var predicate: NSPredicate {
        switch self  {
        case .country(let c):
            return NSPredicate(format: "country = %@", argumentArray: [c])
        case .continent(let c):
            // 谓词的使用: in 关键字
            return NSPredicate(format: "country in %@", argumentArray: [c.countries])
        }
    }

    var managedObject: NSManagedObject? {
        switch self {
        case .country(let c): return c
        case .continent(let c): return c
        }
    }
}


extension MoodSource: LocalizedStringConvertible {
    var localizedDescription: String {
        switch self  {
        case .country(let c): return c.localizedDescription
        case .continent(let c): return c.localizedDescription
        }
    }
}

