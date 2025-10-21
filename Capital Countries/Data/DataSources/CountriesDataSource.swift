import Foundation

protocol CountriesDataSource {
    func createCountry(_ country: Country) throws
    func deleteCountry(id: UUID) throws
    func getCountries(filter: CountryContinent?) throws -> [Country]
    func updateCountry(_ country: Country) throws
}
