//
//  QuestionViewController.swift
//  surveyapp
//
//  Created by YY Tan on 2023-01-03.
//
import UIKit

struct Question {
    var text: String
    var answers: [String]
}

let question1 = Question(text: "On the scale of 1-5, how fast was the pace of this workshop?", answers: [
    "1 - too slow",
    "2 - slow",
    "3 - just right",
    "4 - fast",
    "5 -  too fast"
])

let question2 = Question(text: "On a scale of 1-5, how likely are you to implement a survey app like this on your own?", answers: [
    "1 - very unlikely",
    "2 - unlikely",
    "3 - maybe",
    "4 - likely",
    "5 - very likely"

])
let question3 = Question(text: "Would you recommend this workshop to others?", answers: [
    "Yes",
    "No"
])

let allQuestions = [question1, question2, question3]


class QuestionViewController: UITableViewController {


    
    var currentQuestionIndex = 0
    var localAnswers = [String]() // stores the answers locally before sending to remote database

    /* Uploads the survey answers onto the remote server. */
    private func uploadAnswers(answers: [String]) {
        var urlBuilder = URLComponents(string: "https://auspicious-alike-antimatter.glitch.me")
        urlBuilder?.path = "/survey"
        let surveyAnswersString = localAnswers.joined(separator: ",")
        urlBuilder?.queryItems = [URLQueryItem(name: "answers", value: surveyAnswersString)]

        let url = urlBuilder?.url!
       
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let waitAlert = UIAlertController(title: "Survey completed", message: "Thank you for completing the survey. Your responses are being uploaded :)", preferredStyle: .alert)
        self.present(waitAlert, animated: true)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print(error)
            }
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
            }
            DispatchQueue.main.async {
                waitAlert.dismiss(animated: true) {
                    self?.dismiss(animated: true)
                }
                
            }

            
        }.resume()
    }
    
    // tableview functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let currentQuestion = allQuestions[currentQuestionIndex]
            return currentQuestion.answers.count
        }

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath )
        let currentQuestion = allQuestions[currentQuestionIndex]
        let section = indexPath.section
        let answerIndex = indexPath.row
        if section == 0 {
            cell.textLabel?.text = currentQuestion.text
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = currentQuestion.answers[answerIndex]
            cell.selectionStyle = .default
        }

        // allow text to span multiple lines
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      
        let section = indexPath.section
        let answerIndex = indexPath.row
       
        if section == 0 {
            return
        } else {
            let currentQuestion = allQuestions[currentQuestionIndex]
            let answer = currentQuestion.answers[answerIndex]
            localAnswers.append(answer)
            
            currentQuestionIndex = currentQuestionIndex + 1
            if currentQuestionIndex >= allQuestions.count {
                uploadAnswers(answers: localAnswers)
            } else {
                tableView.reloadData()
            }
            
        }
        

        
    }
}

