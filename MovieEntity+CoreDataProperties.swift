//
//  MovieEntity+CoreDataProperties.swift
//  Movies
//
//  Created by Shreeram Bhat on 11/08/23.
//
//

import Foundation
import CoreData


extension MovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var poster_path: String?

}

extension MovieEntity : Identifiable {

}
