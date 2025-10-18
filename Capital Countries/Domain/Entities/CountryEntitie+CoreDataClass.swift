public import Foundation
public import CoreData

public typealias CountryEntitieCoreDataClassSet = NSSet
public typealias CountryEntitieCoreDataPropertiesSet = NSSet

@objc(CountryEntitie)
public class CountryEntitie: NSManagedObject {

}

extension CountryEntitie {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CountryEntitie> {
        return NSFetchRequest<CountryEntitie>(entityName: "CountryEntitie")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var capital: String?
    @NSManaged public var flag: String?
    @NSManaged public var continent: String?
}
