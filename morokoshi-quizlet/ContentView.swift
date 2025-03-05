//
//  ContentView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/01/24.
//

import SwiftUI

struct Question {
    let questionText: String
    let choices: [String]
    let correctAnswer: String
}

class QuizViewModel: ObservableObject {
    @Published var questions: [Question]
    @Published var incorrectQuestions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var userInput: String = ""
    @Published var showMultipleChoice: Bool = true
    @Published var score: Int = 0

    init(questions: [Question]) {
        self.questions = questions
    }

    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    func checkAnswer(_ answer: String) {
        guard let currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            nextQuestion()
        } else {
            incorrectQuestions.append(currentQuestion)
            nextQuestion()
        }
    }

    func nextQuestion() {
        userInput = ""
        showMultipleChoice.toggle()

        if showMultipleChoice == false {
            // Keep the current question for the second phase
            return
        }

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else if !incorrectQuestions.isEmpty {
            questions = incorrectQuestions
            incorrectQuestions = []
            currentQuestionIndex = 0
        } else {
            // All questions answered correctly
            questions = []
        }
    }
}

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel(questions: [
        Question(questionText: "Swiftの変数を宣言するキーワードは？", choices: ["var", "let", "const", "def"], correctAnswer: "var"),
        Question(questionText: "Swiftで定数を宣言するキーワードは？", choices: ["var", "let", "static", "const"], correctAnswer: "let"),
        Question(questionText: "Swiftのプロトコルは何を定義するためのものですか？", choices: [], correctAnswer: "仕様や契約")
    ])

    var body: some View {
        NavigationView {
            VStack {
                if let question = viewModel.currentQuestion {
                    Text(question.questionText)
                        .font(.title)
                        .padding()

                    if viewModel.showMultipleChoice && !question.choices.isEmpty {
                        ForEach(question.choices, id: \ .self) { choice in
                            Button(action: {
                                viewModel.checkAnswer(choice)
                            }) {
                                Text(choice)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        TextField("答えを入力してください", text: $viewModel.userInput, onCommit: {
                            viewModel.checkAnswer(viewModel.userInput)
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    }
                } else {
                    Text("すべての問題を終了しました！\nスコア: \(viewModel.score)")
                        .font(.title)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .navigationTitle("学習モード")
            .padding()
        }
    }
}


