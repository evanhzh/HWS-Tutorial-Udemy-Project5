//
//  ViewController.swift
//  Project5-WordScramble
//
//  Created by Zhan Hui Hoe on 6/27/17.
//  Copyright © 2017 evanzhoe. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        //1. locate the text file containing words for game
        //2. convert the text file contents into a string starting on a specific path
        //3. break the string into elements and store in an array
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                
                allWords = startWords.components(separatedBy: "\n")
                
            } else {
                allWords = ["silkworm"]
            }
        }
        
        startGame()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func startGame () {
        
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] _ in
            
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        
        //add submit button in UIAlertController!!!Useful
        ac.addAction(submitAction)
        
        present(ac, animated: true)
        
    }
    
    func submit(answer: String) {
        
        let submittedAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: submittedAnswer) {
            if isOriginal(word: submittedAnswer) {
                if isReal(word: submittedAnswer) {
                    
                    usedWords.insert(submittedAnswer.capitalized, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                    
                } else {
                    errorTitle = "Word does not exist"
                    errorMessage = "You cannot make up your own word"
                }
                
            } else {
                errorTitle = "Word already used"
                errorMessage = "Please enter another word"
            }
        } else {
            errorTitle = "Word is not allowed"
            errorMessage = "Please form a word from \(title!.lowercased())!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        
        let dismissBtn = UIAlertAction(title: "Continue", style: .cancel, handler: nil)
        ac.addAction(dismissBtn)
        
        present(ac, animated: true)
        
    }
    
    func isPossible(word: String) -> Bool {
    
        var tempWord = title!.lowercased()
        
        for letter in word.characters {
            
            if let charExist = tempWord.range(of: String(letter)) {
                tempWord.remove(at: charExist.lowerBound)
            } else {
                return false
            }
        }
        
        return true
    
    }
   
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        let spellingChecker = UITextChecker()
        
        let range = NSMakeRange(0, word.utf16.count)
        
        let misspelledRange = spellingChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //NSNotFound is true if no spelling error
        return misspelledRange.location == NSNotFound
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    

}

