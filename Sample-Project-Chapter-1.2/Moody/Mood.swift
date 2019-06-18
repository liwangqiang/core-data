//
//  Model.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData


final class Mood: NSManagedObject {
    @NSManaged fileprivate(set) var date: Date
    @NSManaged fileprivate(set) var colors: [UIColor]
    // 对一关系, 直接声明
    @NSManaged public fileprivate(set) var country: Country

    public var location: CLLocation? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocation(latitude: lat.doubleValue, longitude: lon.doubleValue)
    }

    public static func insert(into context: NSManagedObjectContext, image: UIImage, location: CLLocation?, placemark: CLPlacemark?) -> Mood {
        let mood: Mood = context.insertObject()
        mood.colors = image.moodColors
        mood.date = Date()
        if let coord = location?.coordinate {
            mood.latitude = NSNumber(value: coord.latitude)
            mood.longitude = NSNumber(value: coord.longitude)
        }
        let isoCode = placemark?.isoCountryCode ?? ""
        let isoCountry = ISO3166.Country.fromISO3166(isoCode)
        mood.country = Country.findOrCreate(for: isoCountry, in: context)
        return mood
    }

    override public func prepareForDeletion() {
        ///  以关系的删除规则是无法实现这个功能的.
        if country.moods.filter({ !$0.isDeleted }).isEmpty {
            /// 通过 EntityDescription 插入, 删除可以直接删.
            managedObjectContext?.delete(country)
        }
    }


    // MARK: Private

    @NSManaged fileprivate var latitude: NSNumber?
    @NSManaged fileprivate var longitude: NSNumber?
}

// 遵循协议, 就可以使用协议的一些扩展方法
extension Mood: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(date), ascending: false)]
    }
}


private let MaxColors = 8

extension UIImage {
    fileprivate var moodColors: [UIColor] {
        var colors: [UIColor] = []
        for c in dominantColors(.Moody) where colors.count < MaxColors {
            colors.append(c)
        }
        return colors
    }
}

