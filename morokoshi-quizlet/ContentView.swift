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
    var multipleChoiceCorrect: Bool = false
}

class QuizViewModel: ObservableObject {
    @Published var questionQueue: [Question]
    @Published var completedQuestions: [Question] = []
    @Published var userInput: String = ""
    @Published var score: Int = 0
    @Published var feedbackMessage: String = ""
    @Published var isShowingFeedback: Bool = false
    @Published var lastAnswer: String = ""
    @Published var lastCorrectAnswer: String = ""
    @Published var wasCorrect: Bool = false

    init(questions: [Question]) {
        self.questionQueue = questions.shuffled()
    }

    var currentQuestion: Question? {
        return questionQueue.first
    }

    func showFeedback(answer: String, correctAnswer: String, correct: Bool) {
        lastAnswer = answer
        lastCorrectAnswer = correctAnswer
        wasCorrect = correct
        isShowingFeedback = true
    }

    func dismissFeedback() {
        isShowingFeedback = false
    }

    func checkMultipleChoiceAnswer(_ answer: String) {
        guard var currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            feedbackMessage = "正解！"
            currentQuestion.multipleChoiceCorrect = true
            questionQueue.removeFirst()
            questionQueue.append(currentQuestion)
            showFeedback(
                answer: answer, correctAnswer: currentQuestion.correctAnswer,
                correct: true)
        } else {
            feedbackMessage = "不正解！"
            questionQueue.append(questionQueue.removeFirst())
            showFeedback(
                answer: answer, correctAnswer: currentQuestion.correctAnswer,
                correct: false)
        }
        userInput = ""
    }

    func checkInputAnswer(_ answer: String) {
        guard let currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            feedbackMessage = "正解！"
            completedQuestions.append(currentQuestion)
            questionQueue.removeFirst()
            showFeedback(
                answer: answer, correctAnswer: currentQuestion.correctAnswer,
                correct: true)
        } else {
            feedbackMessage = "不正解！"
            questionQueue.append(questionQueue.removeFirst())
            showFeedback(
                answer: answer, correctAnswer: currentQuestion.correctAnswer,
                correct: false)
        }
        userInput = ""
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

                    if !question.multipleChoiceCorrect
                        && !question.choices.isEmpty
                    {
                        ForEach(question.choices, id: \.self) { choice in
                            Button(action: {
                                viewModel.checkMultipleChoiceAnswer(choice)
                            }) {
                                Text(choice)
                                    .padding()
                            }
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    } else {
                        #if os(macOS)
                            TextField("答えを入力してください", text: $viewModel.userInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        #else
                            TextField("答えを入力してください", text: $viewModel.userInput)
                                .autocapitalization(.none)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        #endif
                        Button(action: {
                            viewModel.checkInputAnswer(viewModel.userInput)
                        }) {
                            Text("送信")
                                .padding()
                        }
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    Text("復習セクション")
                        .font(.title)
                        .padding()
                    ScrollView {
                        LazyVStack {
                            ForEach(
                                viewModel.completedQuestions, id: \.questionText
                            ) { question in
                                VStack(alignment: .leading) {
                                    Text(question.questionText)
                                        .font(.headline)
                                    Text("正解: \(question.correctAnswer)")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.3))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            .overlay(
                VStack {
                    if viewModel.isShowingFeedback {
                        VStack {
                            Text(viewModel.wasCorrect ? "⭕ 正解！" : "❌ 不正解！")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(
                                    viewModel.wasCorrect ? .green : .red
                                )
                                .padding()
                            Text("あなたの答え: \(viewModel.lastAnswer)")
                            Text("正解: \(viewModel.lastCorrectAnswer)")
                                .bold()
                            Button(action: {
                                viewModel.dismissFeedback()
                            }) {
                                Text("次へ")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }.padding()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .transition(.opacity)
                    }
                }
            )
            .navigationTitle("学習モード")
            .padding()
        }
    }
}
