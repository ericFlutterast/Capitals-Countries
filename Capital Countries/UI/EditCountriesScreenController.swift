import UIKit
import Combine
import os

private typealias DataSource = UICollectionViewDiffableDataSource<EditCountriesScreenController.Section, Country>
private typealias Snapshot = NSDiffableDataSourceSnapshot<EditCountriesScreenController.Section, Country>

class EditCountriesScreenController: UIViewController {
    enum Section{
        case main
    }

    var scrollView = UIScrollView()
    private var scrollContainerView = UIView()
    private var contriesDataSource: DataSource!
    
    private var cancellables = Set<AnyCancellable>()
    private var _iteractor: EditCountriesIteractor!
    var iteractor: EditCountriesIteractor {
        get { _iteractor }
    }
    
    private var searchBar: UISearchBar!
    private var countriesCollectionView: UICollectionView!
    private var countriesCollectionHeightConstraint: NSLayoutConstraint!
    private var countriesCount = 0

    private var changesControlSection = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }(UIStackView())
    
    private var emptryPlug = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 16
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        return stack
    }(UIStackView())
    
    init() {
        let dependencies = (UIApplication.shared.delegate as! AppDelegate).dependencies
        _iteractor = EditCountriesIteractor(
            delete: dependencies.resolve(DeleteCountryUseCase.self)!,
            edit: dependencies.resolve(EditCountryUseCase.self)!,
            getAll: dependencies.resolve(FetchCountriesUseCase.self)!,
            logger: dependencies.resolve(Logger.self)!,
            pipe: dependencies.resolve(DefaultPipe.self)!
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        configurateScroll()
        bindData()
        _iteractor.fetchAllCountries()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOusideHandler))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    
    private func configurateScroll()  {
        scrollView.isUserInteractionEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.isUserInteractionEnabled = true
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            scrollContainerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    
    private func bindData() {
        _iteractor.$state.sink { [weak self] stateValue in
            guard let self = self else { return }
            
            switch stateValue {
            case .success(let data): updateUI(countries: data)
            default: break
            }
            
        }.store(in: &cancellables)
    }
    
    private func updateUI(countries: [Country]) {
        if countries.count == 0 && countriesCount > 0 {
            applySnapshot(countries: countries)
            countriesCount = countries.count
            deintegrateUI()
            emptyDataPlug()
            return
        }
        
        if countries.count == 0 {
            countriesCount = countries.count
            emptyDataPlug()
            return
        }
        
        if countries.count > 0 && countriesCount == 0 {
            emptryPlug.removeFromSuperview()
            configurateUI(countryCount: countries.count)
            applySnapshot(countries: countries)
            countriesCount = countries.count
            return
        }
        
        countriesCollectionHeightConstraint.constant = 412 * CGFloat(countries.count)
        applySnapshot(countries: countries)
        countriesCount = countries.count
    }
    
    private func applySnapshot(countries: [Country]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(countries.reversed())
        self.contriesDataSource.apply(snapshot)
    }
    
    private func configurateUI(countryCount: Int) {
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.backgroundColor = .background
        searchBar.placeholder = "Search countries..."
        searchBar.tintColor = .primaryS1
        searchBar.barTintColor = .background
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black

        scrollContainerView.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -10),
        ])

        let saveChangesButton = PrimaryButtonView()
        saveChangesButton.translatesAutoresizingMaskIntoConstraints = false
        saveChangesButton.icon = UIImage(systemName: "folder.fill")
        saveChangesButton.title = "Save Changes"
        saveChangesButton.onTap = {
            print("Save Changes")
        }

        let cancelChangesButton = IconButtonView(onTap: resetChangesHandler, icon: UIImage(systemName: "gobackward"))
        cancelChangesButton.translatesAutoresizingMaskIntoConstraints = false

        changesControlSection.addArrangedSubview(saveChangesButton)
        changesControlSection.addArrangedSubview(cancelChangesButton)

        scrollContainerView.addSubview(changesControlSection)
        NSLayoutConstraint.activate([
            changesControlSection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            changesControlSection.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            changesControlSection.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
        ])

        configurateCollectionView()

        scrollContainerView.addSubview(countriesCollectionView)
        countriesCollectionHeightConstraint = countriesCollectionView.heightAnchor.constraint(equalToConstant: 412 * CGFloat(countryCount))
        NSLayoutConstraint.activate([
            countriesCollectionHeightConstraint,
            countriesCollectionView.topAnchor.constraint(equalTo: changesControlSection.bottomAnchor, constant: 20),
            countriesCollectionView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 0),
            countriesCollectionView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: 0),
            countriesCollectionView.bottomAnchor.constraint(equalTo: scrollContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func deintegrateUI() {
        searchBar.removeFromSuperview()
        changesControlSection.removeFromSuperview()
        countriesCollectionView.removeFromSuperview()
    }
    
    private func emptyDataPlug() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You can create and edit countries here"
        label.textColor = .primaryS1
        label.font = .systemFont(ofSize: 26, weight: .semibold)
        label.numberOfLines = 3
        label.textAlignment = .center
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.tintColor = .primaryS1
        button.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        button.setTitle("Create country", for: .normal)
        button.setTitleColor(.primaryS1, for: .normal)
        button.setTitleColor(.textSecondary, for: .highlighted)
        button.addTarget(self, action: #selector(createCoutryHandler), for: .touchDown)
        
        emptryPlug.addArrangedSubview(label)
        emptryPlug.addArrangedSubview(button)
        
        scrollContainerView.addSubview(emptryPlug)
        NSLayoutConstraint.activate([
            emptryPlug.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: view.bounds.height * 0.2),
            emptryPlug.heightAnchor.constraint(equalToConstant: 150),
            emptryPlug.widthAnchor.constraint(equalToConstant: view.bounds.width - 80),
            emptryPlug.centerXAnchor.constraint(equalTo: scrollContainerView.centerXAnchor),
            emptryPlug.centerYAnchor.constraint(equalTo: scrollContainerView.centerYAnchor),
        ])
    }


    private func configurateCollectionView() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: view.bounds.width - 32, height: 400)
        collectionLayout.minimumLineSpacing = 12

        countriesCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionLayout
        )
        countriesCollectionView.tintColor = .border
        countriesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        countriesCollectionView.backgroundColor = .clear
        countriesCollectionView.keyboardDismissMode = .onDrag
        countriesCollectionView.register(CountryCell.self, forCellWithReuseIdentifier: CountryCell.reuseID)
        configurateDataSource()
    }
    
    private func configurateDataSource() {
        contriesDataSource = DataSource(collectionView: countriesCollectionView, cellProvider: {
            collectionView, indexPath, country in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CountryCell.reuseID, for: indexPath) as? CountryCell else { return nil }
            
            cell.cofigurateWith(country: country)
            
            return cell
        })
    }
    
    // MARK: Handlers
    @objc private func tapOusideHandler() {
        view.endEditing(true)
    }

    @objc private func resetChangesHandler() {
        print("reset changes")
    }

    @objc private func saveChangesHandler() {
        print("saveChangesHandler")
    }
    
    @objc private func createCoutryHandler() {
        //TODO: Move to navigator
        let createCountryController = CreateCountryController()
        
        if let modalController = createCountryController.sheetPresentationController {
            modalController.prefersGrabberVisible = true
            modalController.detents = [.medium(), .large()]
        }
        
        self.present(createCountryController, animated: true)
    }
}

// MARK: - CountriesCollectionDelegate
private final class CountriesCollectionDelegate: NSObject, UICollectionViewDelegate {}



// MARK: - Country Cell
private final class CountryCell: UICollectionViewCell {
    static let reuseID = "CountryCell"
    
    private var currentContinent: CountryContinent? {
        didSet {
            footerSelectContinentButton.setTitle(currentContinent?.rawValue, for: .normal)
        }
    }
    
    private var id: UUID?
    private var flag = UILabel()
    private var name = UILabel()
    private var continent = CustomChipView()
    private var capitalTextField: UITextField!
    private var countryTextField: UITextField!
    private var flagTextField: UITextField!
    
    private lazy var header = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }(UIStackView())
    
    private lazy var footerSelectContinentButton = { button in
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .backgroundSecondary
        button.setTitleColor(.textPrimary, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    } (UIButton())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurateUI() {
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        addInteraction(contextMenuInteraction)
        
        countryTextField = textField()
        flagTextField = textField()
        capitalTextField = textField()
        backgroundColor = .appBar
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.textPrimary.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configurateHeader()
        
        let countryTitle = title()
        countryTitle.text = "Country"
        addSubview(countryTitle)
        NSLayoutConstraint.activate([
            countryTitle.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30),
            countryTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
        ])
        
        let countrySubtitle = subtitle()
        countrySubtitle.text = "English"
        addSubview(countrySubtitle)
        addSubview(countryTextField)
        NSLayoutConstraint.activate([
            countrySubtitle.topAnchor.constraint(equalTo: countryTitle.bottomAnchor, constant: 4),
            countrySubtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            countryTextField.topAnchor.constraint(equalTo: countrySubtitle.bottomAnchor, constant: 8),
            countryTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            countryTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
        
        let capitalTitle = title()
        capitalTitle.text = "Capital"
        addSubview(capitalTitle)
        NSLayoutConstraint.activate([
            capitalTitle.topAnchor.constraint(equalTo: countryTextField.bottomAnchor, constant: 16),
            capitalTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
        ])
        
        let capitalSubtitle = subtitle()
        capitalSubtitle.text = "English"
        addSubview(capitalSubtitle)
        addSubview(capitalTextField)
        NSLayoutConstraint.activate([
            capitalSubtitle.topAnchor.constraint(equalTo: capitalTitle.bottomAnchor, constant: 4),
            capitalSubtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            capitalTextField.topAnchor.constraint(equalTo: capitalSubtitle.bottomAnchor, constant: 8),
            capitalTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            capitalTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
        
        configurateFooter()
    }
    
    private func configurateHeader() {
        flag.translatesAutoresizingMaskIntoConstraints = false
        flag.font = .systemFont(ofSize: 36)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = .systemFont(ofSize: 20, weight: .semibold)
        
        continent.translatesAutoresizingMaskIntoConstraints = false
        
        let columnView = UIStackView(arrangedSubviews: [name, continent])
        columnView.translatesAutoresizingMaskIntoConstraints = false
        columnView.axis = .vertical
        columnView.spacing = 4
        columnView.distribution = .fillEqually
        columnView.alignment = .leading
        
        header.addArrangedSubview(flag)
        header.addArrangedSubview(columnView)
        
        addSubview(header)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            header.topAnchor.constraint(equalTo: topAnchor, constant: 24),
        ])
    }
    
    private func configurateFooter() {
        let flagColumn = footerColumn()
        let continentColumn = footerColumn()
        
        let flagTitle = title()
        flagTitle.text = "Flag"
        
        flagTextField.textAlignment = .center
        flagTextField.font = .systemFont(ofSize: 30)
        flagTextField.widthAnchor.constraint(equalToConstant: (bounds.width - 48) / 2 ).isActive = true
        
        flagColumn.addArrangedSubview(flagTitle)
        flagColumn.addArrangedSubview(flagTextField)
        
        let continentTitle = title()
        continentTitle.text = "Continent"
        
        var menuChildren: [UIMenuElement] = []
        configurateMenuActionsFor(&menuChildren)
        let menu = UIMenu(options: .displayInline, children: menuChildren)
        footerSelectContinentButton.menu = menu
        
        continentColumn.addArrangedSubview(continentTitle)
        continentColumn.addArrangedSubview(footerSelectContinentButton)
        
        let row = UIStackView(arrangedSubviews: [flagColumn, continentColumn])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 16
        row.distribution = .fill
        
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: capitalTextField.bottomAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    private func configurateMenuActionsFor(_ children: inout [UIMenuElement]) {
        let allCountried = CountryContinent.allCases
        for (i, item) in CountryContinent.allCases.enumerated() {
            let action = UIAction(title: item.rawValue, handler: { [weak self] title in
                print(title)
                self?.currentContinent = allCountried[i]
            })
            children.append(action)
        }
        
    }
    
    private func subtitle() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .textSecondary
        return label
    }
    
    private func title() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textPrimary
        return label
    }
    
    private func footerColumn() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fill
        return stack
    }
    
    private func textField() -> PaddedTextField {
        let textField = PaddedTextField()
        textField.isUserInteractionEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .backgroundSecondary
        textField.textColor = .textPrimary
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.padding = UIEdgeInsets.init(top: 12, left: 8, bottom: 12, right: 8)
        return textField
    }
    
    func cofigurateWith(country: Country) {
        id = country.id
        flag.text = country.flag
        name.text = country.name
        continent.title = country.continent.rawValue
        countryTextField.text = country.name
        flagTextField.text = country.flag
        capitalTextField.text = country.capital
        currentContinent = country.continent
        footerSelectContinentButton.setTitle(country.continent.rawValue, for: .normal)
    }
    
    //MARK: Country card handlers
    private func deleteCountry(_ :UIAction) {
        guard let parentController = findUiViewController(ofType: EditCountriesScreenController.self), let id = id else { return }
        parentController.iteractor.deleteCountryBy(id: id)
    }
    
    private func editCountry(_ :UIAction) {
        //guard let parentController = parentViewController else { return }
    }
}

extension CountryCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu in
            let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil"), handler: self.editCountry)
            let deleteAction = UIAction(title: "Dlelete", image: UIImage(systemName: "trash"), attributes: .destructive, handler: self.deleteCountry)
            return UIMenu(children: [editAction, deleteAction])
        }
        
        return configuration
    }
    
}
