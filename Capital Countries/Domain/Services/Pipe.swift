import Foundation
import Combine

protocol Pipe {
    associatedtype Event
    
    func publish(event: Event)
    
    func listen(listener: @escaping (Event) -> Void)
}

final class DefaultPipe: Pipe {
    typealias Event = PipeEvent
    
    private let subject = PassthroughSubject<PipeEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    func publish(event: Event) {
        subject.send(event)
    }
    
    func listen(listener: @escaping (Event) -> Void) {
        subject
            .receive(on: DispatchQueue.main)
            .sink { event in
                listener(event)
            }
            .store(in: &cancellables)
    }
}

enum PipeEvent {
    case fetchAllCountries
}
