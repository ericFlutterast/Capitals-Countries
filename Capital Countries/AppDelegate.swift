import UIKit
import CoreData
import Swinject
import os

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var diContainer: Container!
    var dependencies: Container {
        get { diContainer }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerDependencies()
        return true
    }
    
    private func registerDependencies() {
        diContainer = Container()
        // DataSources
        diContainer.register(CountriesDataSource.self) { [weak self] _ in
            CountriesCoreDataSource(context: self!.persistentContainer.viewContext)
        }
        // Repositories
        diContainer.register(CountriesRepository.self) { r in
            DefaultCountriesRepository(countriesLocatData: r.resolve(CountriesDataSource.self)!)
        }.inObjectScope(.container)
        // UseCases
        diContainer.register(CreateCountryUseCase.self) { r in
            CountryUseCaseImpl(countriesRepository: r.resolve(CountriesRepository.self)!)
        }
        diContainer.register(DeleteCountryUseCase.self) { r in
            CountryUseCaseImpl(countriesRepository: r.resolve(CountriesRepository.self)!)
        }
        diContainer.register(FetchCountriesUseCase.self) { r in
            CountryUseCaseImpl(countriesRepository: r.resolve(CountriesRepository.self)!)
        }
        diContainer.register(EditCountryUseCase.self) { r in
            CountryUseCaseImpl(countriesRepository: r.resolve(CountriesRepository.self)!)
        }
        // Services
        diContainer.register(DefaultPipe.self) { _ in
            DefaultPipe()
        }.inObjectScope(.container)
        diContainer.register(Logger.self) { _ in
            Logger()
        }
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
   
    }

    
    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Capital_Countries")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
