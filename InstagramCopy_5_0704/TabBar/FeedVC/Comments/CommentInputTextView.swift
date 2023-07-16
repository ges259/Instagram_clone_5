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
        let lbl = UILabel()
        
        lbl.text = "Enter comment.."
        lbl.textColor = .lightGray
        
        return lbl
    }()
    
    
    
    
    // MARK: - Handlers
    @objc private func handleInputTextChange() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    
    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.anchor(top: self.topAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor,
                                     leading: self.leadingAnchor, trailing: self.trailingAnchor,
                                     paddingTop: 0, paddingBottom: 10,
                                     paddingLeading: 8, paddingTrailing: 0,
                                     width: 0, height: 0)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
