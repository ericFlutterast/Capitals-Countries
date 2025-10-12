import UIKit

//MARK: LearningModeScreenController
class LearningModeScreenController: UIViewController {
    private let countryCard = CountryCardController()
    
    fileprivate let scrollView = UIScrollView()
    private let scrollContainerView = UIView()
    
    private lazy var scoreCounterView = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }(UIStackView())
    
    private lazy var progressIndicatorView = { progressIndicator in
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.tintColor = .primaryS1
        progressIndicator.backgroundColor = .primaryS3
        progressIndicator.heightAnchor.constraint(equalToConstant: 8).isActive = true
        progressIndicator.layer.cornerRadius = 4
        progressIndicator.layer.masksToBounds = true
        return progressIndicator
    }(UIProgressView(progressViewStyle: .bar))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateScroll()
        configurateUI()
    }
    
    private func configurateScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollContainerView.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.isUserInteractionEnabled = true
        
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
            
            scrollContainerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func configurateUI() {
        view.backgroundColor = .background
        
        let scoreChip = CustomChipView()
        let countCountriesChip = CustomChipView()
        
        scoreChip.title = "Score: 0/25"
        scoreChip.backgroundColor = .border
        scoreChip.translatesAutoresizingMaskIntoConstraints = false
        
        countCountriesChip.title = "1/25"
        countCountriesChip.translatesAutoresizingMaskIntoConstraints = false
        countCountriesChip.backgroundColor = .background
        
        scoreCounterView.addArrangedSubview(scoreChip)
        scoreCounterView.addArrangedSubview(countCountriesChip)
        
        scrollContainerView.addSubview(scoreCounterView)
        NSLayoutConstraint.activate([
            scoreCounterView.topAnchor.constraint(equalTo: scrollContainerView.topAnchor, constant: 16),
            scoreCounterView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
        ])
        
        scrollContainerView.addSubview(progressIndicatorView)
        NSLayoutConstraint.activate([
            progressIndicatorView.topAnchor.constraint(equalTo: scoreCounterView.bottomAnchor, constant: 16),
            progressIndicatorView.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            progressIndicatorView.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
        ])
        
        progressIndicatorView.setProgress(0.2, animated: true)
        
        let countriesGroup = CountryGroupsDropDownView()
        countriesGroup.translatesAutoresizingMaskIntoConstraints = false
        countriesGroup.onSelect = onSelectCountryGroup
        scrollContainerView.addSubview(countriesGroup)
        NSLayoutConstraint.activate([
            countriesGroup.topAnchor.constraint(equalTo: progressIndicatorView.bottomAnchor, constant: 24),
            countriesGroup.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            countriesGroup.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
        ])
        
        addChild(countryCard)
        countryCard.view.translatesAutoresizingMaskIntoConstraints = false
        scrollContainerView.addSubview(countryCard.view)
        NSLayoutConstraint.activate([
            countryCard.view.topAnchor.constraint(equalTo: countriesGroup.bottomAnchor, constant: 24),
            countryCard.view.leadingAnchor.constraint(equalTo: scrollContainerView.leadingAnchor, constant: 16),
            countryCard.view.trailingAnchor.constraint(equalTo: scrollContainerView.trailingAnchor, constant: -16),
            countryCard.view.bottomAnchor.constraint(equalTo: scrollContainerView.bottomAnchor, constant: -16),
        ])
    }
    
    private func onSelectCountryGroup(_ value: String) {
        print(value)
    }
}

//MARK: CountryGroupsDropDownView
private final class CountryGroupsDropDownView: UIView{
    var onSelect: ((String) -> Void)?
    
    private let countriesData: [(String, String)] = [("🌍", "All"),("🇪🇺", "Europe"),("🗽", "America"),("🏯", "Asia"),("🦁", "Africa"),("🏄‍♂️", "Oceania")]
    
    private lazy var selectedValue = "\(countriesData[0].0) \(countriesData[0].1)" {
        didSet {
            buttonView.setTitle(selectedValue, for: .normal)
        }
    }
    
    private lazy var buttonView = { button in
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.textPrimary, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
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
        
        var menuChildren: [UIMenuElement] = []
        configurateActionsFor(&menuChildren)
        buttonView.menu = UIMenu(options: .displayInline, children: menuChildren)
        
        buttonView.setTitle(selectedValue, for: .normal)
        addSubview(buttonView)
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: topAnchor),
            buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func configurateActionsFor(_ children: inout [UIMenuElement]) {
        for (emoji, title) in countriesData {
            let action = UIAction(title: "\(emoji) \(title)", handler: { [weak self] _ in
                self?.selectedValue = "\(emoji) \(title)"
                self?.onSelect?(title)
            })
            children.append(action)
        }
    }
}

//MARK: CountryCardController
private final class CountryCardController: UIViewController {
    private lazy var countryFlagLabet = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 72)
        return label
    }(UILabel())
    
    private lazy var countryTitleLabel = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .primaryS1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }(UILabel())
    
    private var capitalTextInput = { textField in
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Enter the capital..."
        textField.font = .systemFont(ofSize: 20, weight: .regular)
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        textField.backgroundColor = .backgroundSecondary
        textField.layer.cornerRadius = 12
        textField.textColor = .textSecondary
        textField.textAlignment = .center
        textField.autocorrectionType = .default
        textField.spellCheckingType = .default
        textField.tintColor = .primaryS1
        return textField
    }(UITextField())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateUI()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowHandler),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideHandler),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutsideHandler))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    private func configurateUI() {
        view.backgroundColor = .appBar
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)

        countryFlagLabet.text = "🇪🇺"
        view.addSubview(countryFlagLabet)
        NSLayoutConstraint.activate([
            countryFlagLabet.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            countryFlagLabet.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        let capitalQuestionLabel = UILabel()
        capitalQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        capitalQuestionLabel.text = "What is the capital of"
        capitalQuestionLabel.font = .systemFont(ofSize: 17, weight: .medium)
        view.addSubview(capitalQuestionLabel)
        NSLayoutConstraint.activate([
            capitalQuestionLabel.topAnchor.constraint(equalTo: countryFlagLabet.bottomAnchor, constant: 32),
            capitalQuestionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        countryTitleLabel.text = "Australia?"
        view.addSubview(countryTitleLabel)
        NSLayoutConstraint.activate([
            countryTitleLabel.topAnchor.constraint(equalTo: capitalQuestionLabel.bottomAnchor, constant: 16),
            countryTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        
        let playCountry = PlaySountButton()
        playCountry.translatesAutoresizingMaskIntoConstraints = false
        playCountry.onTap = playCountrySoundHandler
        playCountry.title = "Country"

        let playCapital = PlaySountButton()
        playCapital.translatesAutoresizingMaskIntoConstraints = false
        playCapital.onTap = playCountryCapitalSoundHandler
        playCapital.title = "Capital"
        
        let rowOfPalyingButtons = UIStackView()
        rowOfPalyingButtons.translatesAutoresizingMaskIntoConstraints = false
        rowOfPalyingButtons.spacing = 8
        rowOfPalyingButtons.addArrangedSubview(playCountry)
        rowOfPalyingButtons.addArrangedSubview(playCapital)
        view.addSubview(rowOfPalyingButtons)
        NSLayoutConstraint.activate([
            rowOfPalyingButtons.topAnchor.constraint(equalTo: countryTitleLabel.bottomAnchor, constant: 24),
            rowOfPalyingButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        capitalTextInput.delegate = self
        view.addSubview(capitalTextInput)
        NSLayoutConstraint.activate([
            capitalTextInput.topAnchor.constraint(equalTo: rowOfPalyingButtons.bottomAnchor, constant: 24),
            capitalTextInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            capitalTextInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        let rowOfCheckButton = UIStackView()
        rowOfCheckButton.translatesAutoresizingMaskIntoConstraints = false
        rowOfCheckButton.axis = .horizontal
        rowOfCheckButton.spacing = 16
        rowOfCheckButton.distribution = .fill
        
        let checkButton = PrimaryButtonView()
        checkButton.title = "Check"
        checkButton.icon = UIImage(systemName: "checkmark")
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.onTap = checkCapitalHandler
        
        let nextButton = IconButtonView(onTap: nextCountryHandler, icon: UIImage(systemName: "play"))
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.tintColor = .textPrimary
        
        rowOfCheckButton.addArrangedSubview(checkButton)
        rowOfCheckButton.addArrangedSubview(nextButton)
        view.addSubview(rowOfCheckButton)
        NSLayoutConstraint.activate([
            rowOfCheckButton.topAnchor.constraint(equalTo: capitalTextInput.bottomAnchor, constant: 24),
            rowOfCheckButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            rowOfCheckButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            rowOfCheckButton.heightAnchor.constraint(equalToConstant: 52),
            rowOfCheckButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    
    //MARK: Country card handlers
    private func playCountrySoundHandler() {
        print("Play country")
    }
    
    private func playCountryCapitalSoundHandler() {
        print("Play country capital")
    }
    
    private func checkCapitalHandler() {
        print("checkCapitalHandler")
    }
    
    @objc private func nextCountryHandler() {
        print("Next country")
    }
    
    @objc private func keyboardWillShowHandler(_ notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if let parentController = parent as? LearningModeScreenController {
                parentController.scrollView.contentInset.bottom = keyboardSize.height + 30
                print("\(keyboardSize.height)")
            }
        }
    }
    
    @objc private func keyboardWillHideHandler(_ notification: NSNotification) {
        if let parentController = parent as? LearningModeScreenController {
            parentController.scrollView.contentInset.bottom = 0
        }
    }
    
    @objc private func tapOutsideHandler() {
        view.endEditing(true)
    }
}

//MARK: Capital input UITextFieldDelegate
extension CountryCardController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            textField.text = "Enter the capital..."
        }
    }
}

//MARK: PlaySountButton
private final class PlaySountButton: UIView {
    var onTap: (() -> Void)?
    
    var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    private var titleLabel = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }(UILabel())
    
    private lazy var row = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4
        stack.distribution = .fill
        return stack
    }(UIStackView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.border.cgColor
        layer.masksToBounds = true
        

        let uiImage = UIImageView(image: UIImage(systemName: "speaker.wave.3")!)
        uiImage.transform = CGAffineTransformScale(uiImage.transform, 0.7, 0.7)
        uiImage.tintColor = .textPrimary
        row.addArrangedSubview(uiImage)
        row.addArrangedSubview(titleLabel)
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
    
    @objc private func handleTap() {
        onTap?()
    }
}
