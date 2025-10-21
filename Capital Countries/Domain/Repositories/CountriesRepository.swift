import Foundation

protocol CountriesRepository{
    func createCountry(country: Country) throws
    func deleteCountryBy(id: UUID) throws
    func getCountries(filter: CountryContinent?) throws -> [Country]
    func updateCountry(country: Country) throws
}
