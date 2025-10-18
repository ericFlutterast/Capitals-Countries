import Foundation
import CoreData

final class CountriesCoreDataSource: CountriesDataSource {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createCountry(_ country: Country) throws {
        let _ = CountryMapper.toCoreEntitie(country, context: context)
        try context.save()
    }
    
    func updateCountry(_ country: Country) throws {
        let request = CountryEntitie.fetchRequest()
        request.predicate = NSPredicate(format: "\(country.id) == %@", country.id as CVarArg)
        request.fetchLimit = 1
        
        let entitie = try! context.fetch(request).first
        entitie?.name = country.name
        entitie?.capital = country.capital
        entitie?.continent = country.continent.rawValue
        entitie?.flag = country.flag
        try context.save()
    }
    
    func getCountries() throws -> [Country] {
        let request = CountryEntitie.fetchRequest()
        let result = try context.fetch(request)
        return result.map { CountryMapper.toModel($0) }
    }
    
    func deleteCountry(id: UUID) throws {
        let request = CountryEntitie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let entitie = try! context.fetch(request)[0]
        context.delete(entitie)
        try context.save()
    }
}
