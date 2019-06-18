//
//  Region.swift
//  Moody
//
//  Created by Florian on 03/09/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


final class Region: NSManagedObject {}

// 注意这里 Region 并没有和 Country / Continent 托管子类有继承关系

extension Region: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updatedAt", ascending: false)]
    }
}

