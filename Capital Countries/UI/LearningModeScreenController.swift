import UIKit

class LearningModeScreenController: UIViewController {
    
    private lazy var scoreCounterView = { stack in
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        return stack
    }(UIStackView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateUI()
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
        
        view.addSubview(scoreCounterView)
        NSLayoutConstraint.activate([
            scoreCounterView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            scoreCounterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        ])
    }
    
}

private final class CustomChipView: UIView{
    var title: String? {
        didSet {
            titleLabelView.text = title
        }
    }
    
    lazy var titleLabelView = { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textPrimary
        return label
    } (UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    private func configurateUI() {
        layer.cornerRadius = 8
        layer.borderColor = UIColor.border.cgColor
        layer.borderWidth = 1
        
        addSubview(titleLabelView)
        NSLayoutConstraint.activate([
            titleLabelView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            titleLabelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])
    }
}
