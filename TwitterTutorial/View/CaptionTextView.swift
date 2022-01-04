//
//  CaptionTextView.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/28.
//

import UIKit

class CaptionTextView: UITextView {
    
    //MARK: - Properties
    let placeholder:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What's happening"
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 300).isActive = true
        addSubview(placeholder)
        placeholder.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8,paddingLeft: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - selectors
    @objc func handleTextInputChange() {
        placeholder.isHidden = !text.isEmpty
    }
}
