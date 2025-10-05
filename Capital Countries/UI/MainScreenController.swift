import UIKit

class MainScreenController: UIViewController {
    private let learningModeController = LearningModeScreenController()
    private let editCountriesController = EditCountriesScreenController()
    
    private var selectedSegmentIndex = 0 {
        didSet {
            switchContent()
        }
    }
    
    private let navBar = CustomNavBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurateUI()
    }

    private func configurateUI() {
        view.backgroundColor = .background
        
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        navBar.onChangeSegment = { [weak self] index in
            guard let self = self else { return }
            self.selectedSegmentIndex = index
        }
        
        switchContent()
    }
  
    private func switchContent() {
        var content: UIView!
        
        switch selectedSegmentIndex {
        case 0:
            content = learningModeController.view
            addChild(learningModeController)
        case 1: content = editCountriesController.view
            addChild(editCountriesController)
        default:
            fatalError( "Unknown segment index: \(selectedSegmentIndex)" )
        }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

//MARK: NavBar
private final class CustomNavBar: UIView{
    var onChangeSegment: ((Int) -> Void)?
    
    private let segmentTitles = ["Learning Mode", "Edit Countries"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private lazy var segmentControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        segmentControl.tintColor = .appBar
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.primaryS1,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        segmentControl.setTitleTextAttributes(attributes, for: .selected)
        
        return segmentControl
    }()
    
    
    private func configurateUI() {
        backgroundColor = .appBar
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        
        let title = UILabel()
        title.text = "🌍 Capital Countries"
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.textColor = .primaryS1
        
        let languageSelector = LanguageSelectorButton()
        languageSelector.didSelectLanguage = { value in
            print(value)
        }
        
        row.addArrangedSubview(title)
        row.addArrangedSubview(languageSelector)
        
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        addSubview(segmentControl)
        NSLayoutConstraint.activate([
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            segmentControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            segmentControl.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 12),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        addSegmentsActions()
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .border
        addSubview(divider)
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.topAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func addSegmentsActions() {
        for (i, title) in segmentTitles.enumerated() {
            let action = UIAction(title: title, handler: {[weak self] action in
                guard let self = self else { return }
                self.onChangeSegment?(i)
            })
            segmentControl.insertSegment(action: action, at: i, animated: true)
        }
        segmentControl.selectedSegmentIndex = 0
    }
}

//MARK: LanguageSelectorButton
private final class LanguageSelectorButton: UIView{
    var didSelectLanguage: ((String) -> Void)?
    
    private var languagesTitles = [("🇷🇺", "Русский", "RU"), ("🇺🇸", "English", "EN"), ("🇪🇸", "Español", "ES")]
    private lazy var selectedLanguage = "\(languagesTitles[0].0) \(languagesTitles[0].2)" {
        didSet {
            button.setTitle(selectedLanguage, for: .normal)
        }
    }
    
    private lazy var button = { button in
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.textPrimary, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        return button
    }(UIButton(primaryAction: nil))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 8
        
        button.setTitle(selectedLanguage, for: .normal)
        
        var menuChildren: [UIMenuElement] = []
        for item in languagesTitles {
            let action = UIAction(title: "\(item.0) \(item.1)", handler: { [weak self] action in
                guard let self = self else { return }
                selectedLanguage = "\(item.0) \(item.2)"
                self.didSelectLanguage?(selectedLanguage)
            })
            menuChildren.append(action)
        }

        button.menu = UIMenu(options: .displayInline, children: menuChildren)
        
        addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}
