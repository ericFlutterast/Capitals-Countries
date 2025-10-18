import Foundation

struct Country: Identifiable, Hashable, Equatable {
    let id: UUID
    let name: String
    let capital: String
    let flag: String
    let continent: CountryContinent
}

enum CountryContinent: String, CaseIterable {
    case europe = "🇪🇺 Europe"
    case africa = "🦁 Africa"
    case america = "🗽 America"
    case oceania = "🏄‍♂️ Oceania"
    case asian = "🏯 Asia"
}
