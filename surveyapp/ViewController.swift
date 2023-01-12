//
//  ViewController.swift
//  surveyapp
//
//  Created by YY Tan on 2023-01-03.
//

import UIKit

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func startSurvey() {
        let vc = storyboard?.instantiateViewController(identifier: "question") as! QuestionViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

