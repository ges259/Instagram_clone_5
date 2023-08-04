//
//  CommentAccessoryView.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/16.
//

import UIKit

final class CommentAccessoryView: UIView {
    
    // MARK: - Properties
    // CommentVC
    var delegate: CommentInputAccesoryViewDelegate?
    
    
    
    // MARK: - Layout
    private lazy var commentTextView: CommentInputTextView = {
        let tv = CommentInputTextView()
        
            tv.font = UIFont.systemFont(ofSize: 16)
            tv.isScrollEnabled = false
        
        return tv
    }()
    
    private lazy var postButton: UIButton = {
        let btn = UIButton().button(title: "Post",
                                    titleColor: UIColor.black,
                                    fontName: .bold,
                                    fontSize: 14)
            btn.addTarget(self, action: #selector(self.handleUploadComment), for: .touchUpInside)
        return btn
    }()
    
    private lazy var separatorView: UIView = {
        return UIView().backgrouncColorView(backgroundColor: UIColor.rgb(red: 230, green: 230, blue: 230))
    }()

    
    // MARK: - Selectors
    @objc private func handleUploadComment() {
        guard let comment = self.commentTextView.text else { return }
        self.delegate?.didSubmit(forComment: comment)
    }
    

    
    // MARK: - HelperFunctions
    func clearCommentTextView() {
        self.commentTextView.placeholderLabel.isHidden = false
        self.commentTextView.text = nil
    }
    
    // 입력 뷰의 크기를 올바르게 조절하는데 사용
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //
        self.autoresizingMask = .flexibleHeight
        
        // postButton
        self.addSubview(self.postButton)
        self.postButton.anchor(top: self.topAnchor,
                               bottom: self.safeAreaLayoutGuide.bottomAnchor,
                               trailing: self.trailingAnchor, paddingTrailing: 8,
                               width: 50, height: 50)
        // commentTextView
        self.addSubview(self.commentTextView)
        self.commentTextView.anchor(top: self.topAnchor, paddingTop: 8,
                                    bottom: self.safeAreaLayoutGuide.bottomAnchor,
                                    leading: self.leadingAnchor, paddingLeading: 8,
                                    trailing: self.postButton.leadingAnchor, paddingTrailing: 8)
        // separatorView
        self.addSubview(self.separatorView)
        self.separatorView.anchor(top: self.topAnchor,
                                  leading: self.leadingAnchor,
                                  trailing: self.trailingAnchor,
                                  height: 0.5)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






