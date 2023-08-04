//
//  CommentInputTextView.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/16.
//

import UIKit

final class CommentInputTextView: UITextView {
    
    // MARK: - Properties
    
    
    
    // MARK: - Layout
    let placeholderLabel: UILabel = {
        return UILabel().label(labelText: "Enter comment..", LabelTextColor: UIColor.lightGray)
    }()
    
    
    
    // MARK: - Selectors
    @objc private func handleInputTextChange() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    
    
    // MARK: - LifeCycle
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
        // configure UI
        self.configureUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Configure UI
    private func configureUI() {
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.anchor(top: self.topAnchor,
                                     bottom: self.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 10,
                                     leading: self.leadingAnchor, paddingLeading: 8,
                                     trailing: self.trailingAnchor)
    }
}
