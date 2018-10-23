//
//  ViewController.swift
//  TimerIssue
//
//  Created by season on 2018/10/17.
//  Copyright © 2018 season. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ViewController"
        let button = UIButton(frame: CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: 44))
        button.backgroundColor = UIColor.lightGray
        button.setTitle("next Controller", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc
    private func buttonAction() {
        navigationController?.pushViewController(NextController(), animated: true)
    }
}

