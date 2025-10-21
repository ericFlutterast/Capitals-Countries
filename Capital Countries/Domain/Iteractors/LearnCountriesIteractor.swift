import Foundation
import os

enum LearningContriesState{
    case idle
    case loading
    case success(LearningContriesStateValue)
    case successAnswer(LearningContriesStateValue)
    case wrongAnswer
    case endTest((score: Int, countryCounts: Int))
    case error(String?)
}

enum Errors: Error {
    case emptyContries
}

struct LearningContriesStateValue {
    var countries: [Country]
    var current: (index: Int, country: Country)
    var currentProgress: Float = 0
    var currentScore: Int = 0
}

final class LearningCountriesIteractor: ObservableObject {
    @Published var state: LearningContriesState = .idle
    
    private let fetchCountriesUseCase: FetchCountriesUseCase
    private let pipe: DefaultPipe
    private let logger: Logger
    
    init(fetchCountries: FetchCountriesUseCase, logger: Logger, pipe: DefaultPipe) {
        self.fetchCountriesUseCase = fetchCountries
        self.logger = logger
        self.pipe = pipe
        self.fetchCountries()
        
        pipe.listen { [weak self] event in
            switch event {
            case .fetchAllCountries:
                self?.fetchCountries()
            }
        }
    }
    
    func fetchCountries(filter: CountryContinent? = nil) {
        do{
            let result = try fetchCountriesUseCase.execute(filter: filter)
            guard !result.isEmpty else { throw Errors.emptyContries }
            state = .success(LearningContriesStateValue(countries: result, current: (index: 0, country: result[0])))
        } catch {
            logger.error("Fetch contries error: \(error)")
            state = .error("Fetch contries error: \(error)")
        }
    }
    
    func checkAnswer(_ value: String) {
        var oldState: LearningContriesStateValue!
        switch state {
        case .success(let stateValue):
            oldState = stateValue
            if value == stateValue.current.country.capital {
                var newState = stateValue
                newState.currentScore += 1
                state = .successAnswer(newState)
            }else{
                state = .wrongAnswer
            }
        default: break
        }
        
        state = .success(oldState)
    }
    
    func nextCountry() {
        switch state {
        case .successAnswer(let value), .success(let value):
            let nextIndex = value.current.index + 1
            guard nextIndex < value.countries.count else {
                state = .endTest((score: value.currentScore, countryCounts: value.countries.count))
                return
            }
            
            var newState = value
            newState.current = (index: nextIndex, country: newState.countries[nextIndex])
            newState.currentProgress = Float((nextIndex + 1) * 100 / value.countries.count) / 100
            state = .success(newState)
        default: break
        }
    }
}

