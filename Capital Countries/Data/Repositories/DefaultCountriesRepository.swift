import Foundation

final class DefaultCountriesRepository: CountriesRepository {
    private let countriesLocatData: CountriesDataSource
    
    init(countriesLocatData: CountriesDataSource) {
        self.countriesLocatData = countriesLocatData
    }
    
    func createCountry(country: Country) throws {
        try countriesLocatData.createCountry(country)
    }
    
    func deleteCountryBy(id: UUID) throws {
        try countriesLocatData.deleteCountry(id: id)
    }
    
    func updateCountry(country: Country) throws {
        try countriesLocatData.updateCountry(country)
    }
    
    func getCountries() throws -> [Country]  {
        let countries = try countriesLocatData.getCountries()
        return countries
    }
}
