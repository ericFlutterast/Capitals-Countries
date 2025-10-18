import CoreData

final class CountryMapper{
    private init() {}
    
    static func toCoreEntitie(_ country: Country, context: NSManagedObjectContext) -> CountryEntitie {
        let entitie = CountryEntitie(context: context)
        entitie.id = country.id
        entitie.name = country.name
        entitie.capital = country.capital
        entitie.flag = country.flag
        entitie.continent = country.continent.rawValue
        return entitie
    }
    
    static func toModel(_ entitie: CountryEntitie) -> Country {
        Country(
            id: entitie.id!,
            name: entitie.name!,
            capital: entitie.capital!,
            flag: entitie.flag!,
            continent: CountryContinent(rawValue: entitie.continent!)!
        )
    }
}
