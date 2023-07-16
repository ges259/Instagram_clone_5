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
        let btn = UIButton()

        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)

        return btn
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        return view
    }()

    
    // MARK: - Handlers
    @objc private func handleUploadComment() {
        guard let comment = commentTextView.text else { return }
        self.delegate?.didSubmit(forComment: comment)
    }
    
    func clearCommentTextView() {
        commentTextView.placeholderLabel.isHidden = false
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
        
        
        self.addSubview(self.postButton)
        self.postButton.anchor(top: self.topAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor,
                          leading: nil, trailing: self.trailingAnchor,
                          paddingTop: 0, paddingBottom: 0,
                          paddingLeading: 0, paddingTrailing: 8,
                          width: 50, height: 50)
        
        
        self.addSubview(self.commentTextView)
        self.commentTextView.anchor(top: self.topAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor,
                                leading: self.leadingAnchor, trailing: self.postButton.leadingAnchor,
                                paddingTop: 8, paddingBottom: 0,
                                paddingLeading: 8, paddingTrailing: 8,
                                width: 0, height: 0)
        
        
        self.addSubview(self.separatorView)
        self.separatorView.anchor(top: self.topAnchor, bottom: nil,
                             leading: self.leadingAnchor, trailing: self.trailingAnchor,
                             paddingTop: 0, paddingBottom: 0,
                             paddingLeading: 0, paddingTrailing: 0,
                             width: 0, height: 0.5)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






