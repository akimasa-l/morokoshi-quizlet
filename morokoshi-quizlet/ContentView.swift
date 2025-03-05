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
    @Published var questionQueue: [Question]
    @Published var userInput: String = ""
    @Published var isMultipleChoicePhase: Bool = true
    @Published var score: Int = 0
    @Published var feedbackMessage: String = ""

    init(questions: [Question]) {
        self.questionQueue = questions//.shuffled()
    }

    var currentQuestion: Question? {
        return questionQueue.first
    }

    func checkAnswer(_ answer: String) {
        guard let currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            feedbackMessage = "正解！"
            questionQueue.removeFirst()
            isMultipleChoicePhase = true
        } else {
            feedbackMessage = "不正解！\nあなたの答えは：\(answer)\n正しい答えは: \(currentQuestion.correctAnswer)"
            questionQueue.append(questionQueue.removeFirst())
            isMultipleChoicePhase = true
        }
    }

    func moveToInputPhase() {
        isMultipleChoicePhase = false
    }
}

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel(questions: [
        Question(
            questionText: "Swiftの変数を宣言するキーワードは？",
            choices: ["var", "let", "const", "def"], correctAnswer: "var"),
        Question(
            questionText: "Swiftで定数を宣言するキーワードは？",
            choices: ["var", "let", "static", "const"], correctAnswer: "let"),
        Question(
            questionText: "Swiftのプロトコルは何を定義するためのものですか？", choices: [],
            correctAnswer: "仕様や契約"),
    ])

    var body: some View {
        NavigationStack {
            VStack {
                if let question = viewModel.currentQuestion {
                    Text(question.questionText)
                        .font(.title)
                        .padding()

                    if viewModel.isMultipleChoicePhase && !question.choices.isEmpty {
                        ForEach(question.choices, id: \ .self) { choice in
                            Button(action: {
                                viewModel.checkAnswer(choice)
                                if choice == question.correctAnswer {
                                    viewModel.moveToInputPhase()
                                }
                            }) {
                                Text(choice)
                                    .padding()
                            }
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    } else {
                        TextField("答えを入力してください", text: $viewModel.userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        Button(action: {
                            viewModel.checkAnswer(viewModel.userInput)
                        }) {
                            Text("送信")
                                .padding()
                        }
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    Text(viewModel.feedbackMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                        .padding()
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
