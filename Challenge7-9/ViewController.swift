//
//  ViewController.swift
//  Challenge7-9
//
//  Created by Gitko Denis on 04.07.2022.
//

import UIKit

class ViewController: UIViewController {
    var allWords = [String]()
    var currentAnswer: String!
    var userTemplate = "" {
        didSet {
            answerLabel.text = userTemplate
        }
    }
    var usedCharacters = [Character]()
    var triesCount = 7 {
        didSet {
            title = "Guesses left: \(triesCount)"
        }
    }

    @IBOutlet var answerLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Guesses left: \(triesCount)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showTryLetterPrompt))
        
        performSelector(inBackground: #selector(loadWords), with: nil)
    }
    
    @objc func loadWords() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {

                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
//        Remove the last element, which is an empty newline
        allWords.removeLast()
        
        allWords.shuffle()
        
        DispatchQueue.main.async {
            self.userTemplate = ""
            self.usedCharacters.removeAll()
            self.triesCount = 7
            
            self.currentAnswer = self.allWords[0]
            for _ in 0..<self.currentAnswer.count {
                self.userTemplate.insert("?", at: self.userTemplate.startIndex)
            }
            self.answerLabel.text = self.userTemplate
        }
    }
    
    @objc func showTryLetterPrompt() {
        let ac = UIAlertController(title: "Enter a letter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
//        Empty the template on screen in order to check if new letters have been guessed and insert them
        userTemplate = ""
        
        let lowerAnswer = answer.lowercased()
        var errorTitle: String
        var errorMessage: String

        if !isOneCharacter(character: lowerAnswer) {
            errorTitle = "Not one letter"
            errorMessage = "Use one letter at a time!"
            showErrorMessage(title: errorTitle, message: errorMessage)
        }
        else if wasAlreadyUsed(character: lowerAnswer) {
            errorTitle = "You've a already used this letter"
            errorMessage = "Be more original"
            showErrorMessage(title: errorTitle, message: errorMessage)
        }
        else if !isExisting(character: lowerAnswer) {
            errorTitle = "Ooops"
            errorMessage = "Looks like there's no such letter"
            triesCount -= 1
//        If there's no more tries left, show "You lost alert", else just decreases tries count by one and show "Looks like there's no such letter" alert
            if triesCount == 0 {
                let ac = UIAlertController(title: "You lost!", message: "That was \(currentAnswer!.uppercased())!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Play again", style: .default, handler: nil))
                present(ac, animated: true)
                loadWords()
            } else {
                showErrorMessage(title: errorTitle, message: errorMessage)
            }
        } else {
            for char in currentAnswer {
                if char == Character(answer) {
                    usedCharacters += answer
                }
            }
        }
        
            for char in currentAnswer {
                if usedCharacters.contains(char) {
                        userTemplate += String(char)
                    } else {
                        userTemplate += "?"
                    }
            }
            if currentAnswer.count == usedCharacters.count {
                let ac = UIAlertController(title: "Congratulations!", message: "It's \(currentAnswer.uppercased())", preferredStyle: .alert)
                let startGame = UIAlertAction(title: "Play again", style: .default) { [weak self] action in
                    self?.loadWords()
                }
                ac.addAction(startGame)
                present(ac, animated: true)
            }

        
    }
    
    func isOneCharacter(character: String) -> Bool {
        character.count == 1
    }
    func isExisting(character: String) -> Bool {
        currentAnswer.contains(character)
    }
    func wasAlreadyUsed(character: String) -> Bool {
        usedCharacters.contains(Character(character))
    }
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(ac, animated: true)
    }
}

