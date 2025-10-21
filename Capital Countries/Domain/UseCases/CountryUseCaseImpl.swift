import Foundation

protocol CreateCountryUseCase {
    func execute(countyCreate: Country) throws
}

protocol DeleteCountryUseCase{
    func execute(_ id: UUID) throws
}

protocol EditCountryUseCase{
    func execute(countryEdit: Country) throws
}

protocol FetchCountriesUseCase {
    func execute(filter: CountryContinent?) throws -> [Country]
}

final class CountryUseCaseImpl: CreateCountryUseCase, DeleteCountryUseCase, FetchCountriesUseCase, EditCountryUseCase {
    private var countriesRepository: CountriesRepository
    
    init(countriesRepository: CountriesRepository) {
        self.countriesRepository = countriesRepository
    }
    
    func execute(filter: CountryContinent?) throws -> [Country] {
        try countriesRepository.getCountries(filter: filter)
    }
    
    func execute(_ id: UUID) throws {
        try countriesRepository.deleteCountryBy(id: id)
    }
    
    func execute(countyCreate: Country) throws {
        try countriesRepository.createCountry(country: countyCreate)
    }
    
    func execute(countryEdit: Country) throws {
        try countriesRepository.updateCountry(country: countryEdit)
    }
}
