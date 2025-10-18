import Foundation
import Combine
import os

enum EditCountriesState{
    case idle
    case loading
    case success([Country])
    case error(String?)
}

enum EditCountriesIteractorError: Error {
    case deleteError
}

final class EditCountriesIteractor: ObservableObject {
    @Published var state: EditCountriesState = .idle
    
    private let delete: DeleteCountryUseCase
    private let edit: EditCountryUseCase
    private let getAll: FetchCountriesUseCase
    private let logger: Logger
    private let pipe: DefaultPipe
    
    init(delete: DeleteCountryUseCase, edit: EditCountryUseCase, getAll: FetchCountriesUseCase, logger: Logger, pipe: DefaultPipe) {
        self.delete = delete
        self.edit = edit
        self.getAll = getAll
        self.logger = logger
        self.pipe = pipe
        
        self.pipe.listen { event in
            switch event {
            case .fetchAllCountries: self.fetchAllCountries()
            }
        }
    }
    
    func deleteCountryBy(id: UUID) {
        do {
            switch state {
            case .success(let data):
                var newData = data
                try delete.execute(id)
                newData.removeAll { $0.id == id }
                state = .success(newData)
            default:
                throw EditCountriesIteractorError.deleteError
            }

        } catch {
            logger.error("Execute delete country failed: \(error)")
            state = .error("Execute delete country failed")
        }
    }
    
    func editCountry(_ country: Country) {
        do{
            try edit.execute(countryEdit: country)
        } catch {
            logger.error("Execute edit country failed: \(error)")
            state = .error("Execute edit country failed")
        }
    }
    
    func fetchAllCountries() {
        state = .loading
        do{
            let result = try getAll.execute()
            state = .success(result)
        } catch {
            logger.error("Execute fetch all countries failed: \(error)")
            state = .error("Execute fetch all countries failed")
        }
    }
}
