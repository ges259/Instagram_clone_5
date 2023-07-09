//
//  TFExtensions.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/05.
//

import UIKit

class InsetTextField: UITextField {
    var insetX: CGFloat = 0 {
        didSet {
            layoutIfNeeded()
        }
    }
    var insetY: CGFloat = 0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    // insetX와 insetY의 값에 따라서 텍스트영역을 조절하도록 바꿀 것
        // -> textRect를 오버리이드
            // textRect: textField의 텍스트 영역을 지정해주는 함수
            // + 추가설명: 입력 중이 아닌 resignFirstResponder 상태일 경우의 입력된 위치
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // 원래 영역보다 insetX, insetY만큼 값이 작아지게 됨
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // 입력중의 텍스트 위치 설정
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // placeholderRect(bounds:) => 플레이스홀더의 위치 설정
}
