//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

//class 나중에생기는데이터<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//
//    func 나중에오면(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe
    // 3. onNext
    // ---- 끝 ----
    // 4. onCompleted  /  onError
    // 5. Disposed

    func downloadJson(_ url: String) -> Observable<String> {

        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    emitter.onError(error!)
                    return
                }

                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }
            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)

        // 2. Obsevable로 오는 데이터를 받아서 처리하는 방법
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")

        Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0 }
            .observeOn(MainScheduler.instance) // sugar: operator
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            .disposed(by: disposeBag)
    }
}
