import Foundation
import os

enum CreateCountryState{
    case idle
    case loading
    case success
    case error(String?)
}

final class CreateCountryIteractor: ObservableObject {
    @Published var state: CreateCountryState = .idle
    
    private let create: CreateCountryUseCase
    private let logger: Logger
    private let pipe: DefaultPipe
    
    init(create: CreateCountryUseCase, logger: Logger, pipe: DefaultPipe) {
        self.create = create
        self.logger = logger
        self.pipe = pipe
    }
    
    func createCountry(_ country: Country) {
        do {
            try create.execute(countyCreate: country)
            pipe.publish(event: .fetchAllCountries)
        } catch {
            logger.error("Execute create country failed: \(error)")
            state = .error("Execute create country failed")
        }
    }
}
