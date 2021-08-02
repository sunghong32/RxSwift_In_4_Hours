//
//  ViewModel.swift
//  RxSwiftIn4Hours
//
//  Created by 민성홍 on 2021/08/02.
//  Copyright © 2021 n.code. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {

    // input
    let emailText = BehaviorSubject(value: "")
    let pwText = BehaviorSubject(value: "")

    // output
    let isEmailValid = BehaviorSubject<Bool>(value: false)
    let isPasswordValid = BehaviorSubject<Bool>(value: false)

    init() {
        _ = emailText.distinctUntilChanged()
            .map(checkEmailValid)
            .bind(to: isEmailValid)

        _ = pwText.distinctUntilChanged()
            .map(checkPasswordValid)
            .bind(to: isPasswordValid)
    }

    // MARK: - Logic

    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }

    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
}
