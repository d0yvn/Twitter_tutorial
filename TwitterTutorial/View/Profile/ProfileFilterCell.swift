import UIKit

class ProfileFilterCell: UICollectionViewCell {
    
    //MARK: - Property
    var option : ProfileFilterOptions! {
        didSet{ titleLabel.text = option.description }
    }
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "Test Filter"
        label.font = UIFont.systemFont(ofSize: 14)

        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.systemFont(ofSize: 16) :
                UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? .twitterBlue : .lightGray
        }
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
