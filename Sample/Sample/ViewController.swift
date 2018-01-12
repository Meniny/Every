//
//  ViewController.swift
//  Sample
//
//  Created by 李二狗 on 2018/1/12.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import Every

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var counter = 0
        Every(1).seconds.do { () -> Every.NextStep in
            counter += 1
            guard counter <= 4 else {
                print("STOP")
                return .stop
            }
            print(counter)
            return .continue
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

