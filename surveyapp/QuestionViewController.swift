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

let answers1 = [
    "1 - too slow",
    "2 - slow",
    "3 - just right",
    "4 - fast",
    "5 -  too fast"
]
let question1 = Question(text: "On the scale of 1-5, how fast was the pace of this workshop?",
                         answers: answers1)

let answers2 = [
    "1 - very unlikely",
    "2 - unlikely",
    "3 - maybe",
    "4 - likely",
    "5 - very likely"
]
let question2 = Question(text: "On a scale of 1-5, how likely are you to implement a survey app like this on your own?",
                         answers:answers2)

let answers3 = [
    "Yes",
    "No"
]
let question3 = Question(text: "Would you recommend this workshop to others?",
                         answers: answers3)

/* Store all questions in array allQuestions*/
let allQuestions = [question1, question2, question3]


class QuestionViewController: UITableViewController {


    var currentQuestionIndex = 0 // keeps track of index of current question
    var localAnswers = [String]() // stores the answers locally before sending to remote database
    
    override func viewDidLoad() {
        self.title = "My Survey"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    /* Uploads the survey answers onto the remote server. */
    private func uploadAnswers(answers: [String]) {
        var urlBuilder = URLComponents(string: "https://auspicious-alike-antimatter.glitch.me")
        urlBuilder?.path = "/survey"
        
        // create comma separated values based on answers
        let surveyAnswersString = localAnswers.joined(separator: ",")
        
        // add answers to end of url
        urlBuilder?.queryItems = [URLQueryItem(name: "answers", value: surveyAnswersString)]

        let url = urlBuilder?.url!
       
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        // show popup alert with a message
        let waitAlert = UIAlertController(title: "Survey completed",
                                          message: "Thank you for completing the survey. Your responses are being uploaded :)",
                                          preferredStyle: .alert)
        
        self.present(waitAlert, animated: true)
        
        // start the transmission
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // this block of code runs when the request is finished
            if let error = error {
                print(error)
            }
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
            }
            // on the UI thread:
            DispatchQueue.main.async {
                // dismiss the alert, then dismiss the QuestionViewController (self)
                waitAlert.dismiss(animated: true) {
                    self?.dismiss(animated: true)
                }
                
            }

            
        }.resume() // dont forget to call resume() to actually start the request
    }
    
    // tableview functions
    
    /* Returns number of sections in the table view. First for the question text, secoond for the answer cells.
     A required method under UITableViewDataSource protocol.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /* Returns the number of rows or cells in each section. Allows us to specify same or different number of rows for different sections.*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // one row/cell for the question text
        } else {
            let currentQuestion = allQuestions[currentQuestionIndex]
            return currentQuestion.answers.count // number of rows/cells = number of possible answers for each question
        }

    }
    
    /* Creates and configure rows. Updates the question text in the first section, and text displayed on the answer cells accordingly. */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath ) // retrieves a reusable cell object for the text updates
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
    
    /* Informs the view controller that an answer has been selected. Moves to the next question or ends the survey if all questions have been answered. */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
      
        let section = indexPath.section
        let answerIndex = indexPath.row
       
        if section == 0 {
            return
        } else {
            
            // get the text of the selected answer based on the row number and save it
            let currentQuestion = allQuestions[currentQuestionIndex]
            let answer = currentQuestion.answers[answerIndex]
            localAnswers.append(answer)
            
            // move to the next question
            currentQuestionIndex = currentQuestionIndex + 1
            // upload answers onto server if all questions have been answered
            if currentQuestionIndex >= allQuestions.count {
                uploadAnswers(answers: localAnswers)
            } else {
                // show the new question/answers in the table view
                tableView.reloadData()
            }
            
        }
        

        
    }
}

