import UIKit
import os

class CreateCountryController: UIViewController {
    private var selectedContinent = CountryContinent.europe.rawValue {
        didSet {
            updateSelectedContinent()
        }
    }
    
    private var iteractor: CreateCountryIteractor!
    private var saveButtonBottomContraints: NSLayoutConstraint!
    
    private var countryNameField: PaddedTextField!
    private var countryCapitalField: PaddedTextField!
    private var flagField: PaddedTextField!
    private var isSaveDisabled = true {
        didSet {
            saveButton.isDisabled = isSaveDisabled
        }
    }
    
    private lazy var saveButton = { button in
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = "Save"
        button.isDisabled = isSaveDisabled
        button.onTap = saveButtonHandler
        return button
    }(PrimaryButtonView())
    
    init(){
        let dependencies = (UIApplication.shared.delegate as! AppDelegate).dependencies
        iteractor = CreateCountryIteractor(
            create: dependencies.resolve(CreateCountryUseCase.self)!,
            logger: dependencies.resolve(Logger.self)!,
            pipe: dependencies.resolve(DefaultPipe.self)!
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var continentSelector = {
        let button = UIButton(primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.border.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.backgroundColor = .backgroundSecondary
        button.setTitleColor(.textPrimary, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        configurateUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardHide))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func keyboardShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            saveButtonBottomContraints.constant = -keyboardSize.height + 16
        }
    }
    
    @objc private func keyboardHide() {
        view.endEditing(true)
        saveButtonBottomContraints.constant = 0
    }
    
    
    private func configurateUI() {
        let countryTitle = title()
        countryTitle.text = "Country name"
        countryNameField = textField()
        countryNameField.placeholder = "Country name"
        countryNameField.addTarget(self, action: #selector(onChange), for: .editingChanged)
        view.addSubview(countryTitle)
        view.addSubview(countryNameField)
        NSLayoutConstraint.activate([
            countryTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 48),
            countryTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            countryNameField.topAnchor.constraint(equalTo: countryTitle.bottomAnchor, constant: 8),
            countryNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countryNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        let countryCapitalTitle = title()
        countryCapitalTitle.translatesAutoresizingMaskIntoConstraints = false
        countryCapitalTitle.text = "Country capital"
        countryCapitalField = textField()
        countryCapitalField.addTarget(self, action: #selector(onChange), for: .editingChanged)
        countryCapitalField.placeholder = "Capital name"
        view.addSubview(countryCapitalTitle)
        view.addSubview(countryCapitalField)
        NSLayoutConstraint.activate([
            countryCapitalTitle.topAnchor.constraint(equalTo: countryNameField.bottomAnchor, constant: 16),
            countryCapitalTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countryCapitalTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            countryCapitalField.topAnchor.constraint(equalTo: countryCapitalTitle.bottomAnchor, constant: 8),
            countryCapitalField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            countryCapitalField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        let flagTitle = title()
        flagTitle.text = "Flag"
        flagField = textField()
        flagField.placeholder = "Flag"
        flagField.addTarget(self, action: #selector(onChange), for: .editingChanged)
        view.addSubview(flagTitle)
        view.addSubview(flagField)
        NSLayoutConstraint.activate([
            flagTitle.topAnchor.constraint(equalTo: countryCapitalField.bottomAnchor, constant: 16),
            flagTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            flagField.topAnchor.constraint(equalTo: flagTitle.bottomAnchor, constant: 8),
            flagField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            flagField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        let continentTitle = title()
        continentTitle.text = "Continent"
        view.addSubview(continentTitle)
        NSLayoutConstraint.activate([
            continentTitle.topAnchor.constraint(equalTo: flagField.bottomAnchor, constant: 16),
            continentTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
        
        updateSelectedContinent()
        var menuChildren = [UIMenuElement]()
        configurateUIMenuElements(&menuChildren)
        continentSelector.menu = UIMenu(children: menuChildren)
   
        view.addSubview(continentSelector)
        NSLayoutConstraint.activate([
            continentSelector.topAnchor.constraint(equalTo: continentTitle.bottomAnchor, constant: 8),
            continentSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continentSelector.widthAnchor.constraint(equalToConstant: (view.bounds.width / 2) - 16),
        ])
        
        saveButtonBottomContraints = saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButtonBottomContraints,
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func updateSelectedContinent() {
        continentSelector.setTitle(selectedContinent, for: .normal)
    }
    
    private func configurateUIMenuElements(_ children: inout [UIMenuElement]) {
        let continetns = CountryContinent.allCases
        
        for continent in continetns {
            let action = UIAction(title: continent.rawValue) { [weak self] action in
                print(action.title)
                self?.selectedContinent = continent.rawValue
            }
            children.append(action)
        }
    }
    
    private func title() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textPrimary
        return label
    }
    
    private func textField() -> PaddedTextField {
        let textField = PaddedTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .backgroundSecondary
        textField.textColor = .textPrimary
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.padding = UIEdgeInsets.init(top: 12, left: 8, bottom: 12, right: 8)
        return textField
    }
    
    //MARK: Handlers
    private func saveButtonHandler() {
        guard !isSaveDisabled else { return }
        
        let country = Country(
            id: UUID(),
            name: countryNameField.text!,
            capital: countryCapitalField.text!,
            flag: flagField.text!,
            continent: CountryContinent(rawValue: self.selectedContinent)!,
        )
        iteractor.createCountry(country)
        self.dismiss(animated: true)
    }
    
    @objc private func onChange() {
        isSaveDisabled = chacheSaveButtonDisable()
    }
    
    private func chacheSaveButtonDisable() -> Bool {
        if let countryName = countryNameField.text, let capitalName = countryCapitalField.text, let flag = flagField.text, !countryName.isEmpty && !capitalName.isEmpty && !flag.isEmpty {
            return false
        }
        
        return true
    }
}
