//
//  QuizView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/01/24.
//

import SwiftUI

enum FocusTextFields: Hashable {
    case question
    case retry
}

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
    @Published var isShowingFeedback: Bool = false
    @Published var lastQuestion: String = ""
    @Published var lastAnswer: String = ""
    @Published var lastCorrectAnswer: String = ""
    @Published var wasCorrect: Bool = false
    @Published var retryInput: String = ""
    @Published var isRetryAnswered: Bool = false
    @Published var isRetryCorrect: Bool = false
    @Published var needsRetry: Bool = false

    init(questions: [Question]) {
        self.questionQueue = questions.shuffled()
    }

    var currentQuestion: Question? {
        return questionQueue.first
    }

    func showFeedback(
        question: String, answer: String, correctAnswer: String, correct: Bool,
        needsRetry: Bool = false
    ) {
        lastQuestion = question
        lastAnswer = answer
        lastCorrectAnswer = correctAnswer
        wasCorrect = correct
        self.needsRetry = needsRetry
        isShowingFeedback = true
    }

    func updateFeedback(answer: String, correct: Bool) {
        lastAnswer = answer
        isRetryCorrect = correct
        isShowingFeedback = true
    }

    func dismissFeedback() {
        isShowingFeedback = false
        isRetryAnswered = false
        isRetryCorrect = false
        wasCorrect = false
        needsRetry = false
    }

    func checkMultipleChoiceAnswer(_ answer: String) {
        guard var currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            currentQuestion.multipleChoiceCorrect = true
            questionQueue.removeFirst()
            questionQueue.append(currentQuestion)
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: true)
        } else {
            questionQueue.append(questionQueue.removeFirst())
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: false)
        }
        userInput = ""
    }

    func checkInputAnswer(_ answer: String) {
        guard let currentQuestion = currentQuestion else { return }
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            score += 1
            completedQuestions.append(currentQuestion)
            questionQueue.removeFirst()
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: true)
        } else {
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: false,
                needsRetry: true)
        }
        userInput = ""
    }

    func checkRetryInputAnswer(_ answer: String) {
        isRetryAnswered = true
        if answer.lowercased() == lastCorrectAnswer.lowercased() {
            score += 1
            updateFeedback(answer: retryInput, correct: true)
            retryInput = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.dismissFeedback()
            }
        } else {
            updateFeedback(answer: retryInput, correct: false)
            retryInput = ""
        }
    }
}

struct QuizView: View {
    @FocusState private var focusTextFields: FocusTextFields?
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
                            TextField(
                                "答えを入力してください", text: $viewModel.userInput
                            ) {
                                viewModel.checkInputAnswer(
                                    viewModel.userInput)

                                if viewModel.isShowingFeedback {
                                    focusTextFields = .retry
                                }
                            }.focused($focusTextFields, equals: .question)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        #else
                            TextField("答えを入力してください", text: $viewModel.userInput)
                            {
                                viewModel.checkInputAnswer(
                                    viewModel.userInput)
                                if viewModel.isShowingFeedback {
                                    focusTextFields = .retry
                                }
                            }
                            .focused($focusTextFields, equals: .question)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        #endif
                        Button(action: {
                            viewModel.checkInputAnswer(viewModel.userInput)
                            if viewModel.isShowingFeedback {
                                focusTextFields = .retry
                            }
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
                            if !viewModel.isRetryAnswered {
                                Text(
                                    viewModel.wasCorrect
                                        ? "⭕ 正解！" : "❌ 不正解！ もう一度試してください"
                                )
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(
                                    viewModel.wasCorrect ? .green : .red)
                            } else {
                                Text(
                                    viewModel.isRetryCorrect
                                        ? "⭕ 正解！その調子です！" : "❌ 不正解！ もう一度試してください"
                                )
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(
                                    viewModel.isRetryCorrect ? .green : .red)
                            }
                            Text("問題: \(viewModel.lastQuestion)")
                                .font(.headline)
                                .padding(.top, 5)
                            Text("あなたの答え: \(viewModel.lastAnswer)")
                            Text("正解: \(viewModel.lastCorrectAnswer)")
                                .bold()
                            if viewModel.needsRetry {

                                #if os(macOS)
                                    TextField(
                                        "もう一度入力してください",
                                        text: $viewModel.retryInput
                                    ) {
                                        viewModel.checkRetryInputAnswer(
                                            viewModel.retryInput)
                                        if viewModel.isRetryCorrect {
                                            focusTextFields = nil
                                        }

                                    }
                                    .focused($focusTextFields, equals: .retry)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                                    .padding()
                                #else
                                    TextField(
                                        "もう一度入力してください",
                                        text: $viewModel.retryInput
                                    ) {
                                        viewModel.checkRetryInputAnswer(
                                            viewModel.retryInput)
                                        if viewModel.isRetryCorrect {
                                            focusTextFields = nil
                                        }
                                    }
                                    .focused($focusTextFields, equals: .retry)
                                    .autocapitalization(.none)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                                    .padding()
                                #endif
                                Button(action: {
                                    viewModel.checkRetryInputAnswer(
                                        viewModel.retryInput)
                                }) {
                                    Text("再送信")
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            } else {
                                Button(action: {
                                    viewModel.dismissFeedback()
                                }) {
                                    Text("次へ")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
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
