//
//  Question.swift
//  Quizzler-iOS13
//
//  Created by Georgi Popov on 28.12.23.
//

import Foundation

struct Question {
    let text: String
    let answer: [String]
    let correctAnswer: String
    
    init(q: String, a: [String], correctAnswer: String){
        text = q
        answer = a
        self.correctAnswer = correctAnswer
    }
}
