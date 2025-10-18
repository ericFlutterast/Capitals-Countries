import Foundation

protocol CountriesRepository{
    func createCountry(country: Country) throws
    func deleteCountryBy(id: UUID) throws
    func getCountries() throws -> [Country] 
    func updateCountry(country: Country) throws
}
