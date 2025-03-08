//
//  QuizView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/01/24.
//

import SwiftUI

enum QuestionStatus: Hashable {
    case notStarted
    case started
    case completed
    mutating func markAsCompleted() {
        self = .completed
    }
    mutating func markAsStarted() {
        self = .started
    }
}

extension QuestionStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .notStarted:
            return "🔴"
        case .started:
            return "🟡"
        case .completed:
            return "✅"
        }
    }
    var isCompleted: Bool {
        self == .completed
    }
}

enum FocusTextFields: Hashable {
    case question
    case retry
}

struct Question: Hashable {
    let questionText: String
    let choices: [String]
    let correctAnswer: String
    var multipleChoiceCorrect: Bool = false
    var isCompleted: QuestionStatus = .notStarted
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
        self.questionQueue = questions  //.shuffled()
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
        print("ここから")
        print(questionQueue)
        print("ここまで")
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
        currentQuestion.isCompleted.markAsStarted()
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
        guard var currentQuestion = currentQuestion else { return }
        currentQuestion.isCompleted.markAsStarted()
        if answer.lowercased() == currentQuestion.correctAnswer.lowercased() {
            currentQuestion.isCompleted.markAsCompleted()
            score += 1
            completedQuestions.append(currentQuestion)
            questionQueue.removeFirst()
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: true
            )
        } else {
            questionQueue.append(questionQueue.removeFirst())
            showFeedback(
                question: currentQuestion.questionText, answer: answer,
                correctAnswer: currentQuestion.correctAnswer, correct: false,
                needsRetry: true
            )
        }
        userInput = ""
    }

    func checkRetryInputAnswer(_ answer: String) {
        isRetryAnswered = true
        if answer.lowercased() == lastCorrectAnswer.lowercased() {
            // 復習問題があっていた時
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
    @ObservedObject var viewModel: QuizViewModel
    @Binding var isCompleted: QuestionStatus

    var body: some View {
        if let question = viewModel.currentQuestion {
            VStack {
                // まだ問題が存在するなら
                Text(question.questionText)
                    .font(.title)
                    .padding()

                if !question.multipleChoiceCorrect
                    && !question.choices.isEmpty  // 複数選択肢を正解してないし、複数選択肢が存在するとき
                {
                    // 選択肢問題を出す
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
                    // 選択肢が存在しない or 複数選択肢を正解した時
                    //　入力問題を出す
                    #if os(macOS)
                        TextField(
                            "答えを入力してください", text: $viewModel.userInput
                        ) {
                            viewModel.checkInputAnswer(viewModel.userInput)
                            if viewModel.isShowingFeedback {
                                focusTextFields = .retry
                            }
                        }.focused($focusTextFields, equals: .question)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    #else
                        TextField("答えを入力してください", text: $viewModel.userInput) {
                            viewModel.checkInputAnswer(viewModel.userInput)
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
                Spacer()
            }.onAppear { isCompleted.markAsStarted() }
                .overlay {
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
                                            ? "⭕ 正解！その調子です！"
                                            : "❌ 不正解！ もう一度試してください"
                                    )
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(
                                        viewModel.isRetryCorrect ? .green : .red
                                    )
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
                                        .focused(
                                            $focusTextFields, equals: .retry
                                        )
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
                                        .focused(
                                            $focusTextFields, equals: .retry
                                        )
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
                }.navigationTitle("学習モード")
        } else {
            //　問題が存在しない時
            VStack {
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
                Spacer()
            }.onAppear {
                isCompleted.markAsCompleted()
            }
        }

    }
}
