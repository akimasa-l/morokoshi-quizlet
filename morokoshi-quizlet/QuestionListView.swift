//
//  QuestionListView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/03/08.
//

import SwiftUI

struct QuestionListView: View {
    let questionsList: [[Question]] = [
        [
            Question(
                questionText: "Swiftの変数を宣言するキーワードは？",
                choices: ["var", "let", "const", "def"], correctAnswer: "var"),
            Question(
                questionText: "Swiftで定数を宣言するキーワードは？",
                choices: ["var", "let", "static", "const"], correctAnswer: "let"
            ),
            Question(
                questionText: "Swiftのプロトコルは何を定義するためのものですか？", choices: [],
                correctAnswer: "仕様や契約"),
        ],
        [
            Question(
                questionText: "Swiftの変数を宣言するキーワードは？",
                choices: ["var", "let", "const", "def"], correctAnswer: "var"),
            Question(
                questionText: "Swiftで定数を宣言するキーワードは？",
                choices: ["var", "let", "static", "const"], correctAnswer: "let"
            ),
            Question(
                questionText: "Swiftのプロトコルは何を定義するためのものですか？", choices: [],
                correctAnswer: "仕様や契約"),
        ],
        [
            Question(
                questionText: "Swiftの変数を宣言するキーワードは？",
                choices: ["var", "let", "const", "def"], correctAnswer: "var"),
            Question(
                questionText: "Swiftで定数を宣言するキーワードは？",
                choices: ["var", "let", "static", "const"], correctAnswer: "let"
            ),
            Question(
                questionText: "Swiftのプロトコルは何を定義するためのものですか？", choices: [],
                correctAnswer: "仕様や契約"),
        ],
    ]
    @State private var isCompletedList: [QuestionStatus]
    var quizViewModels: [QuizViewModel]
    init() {
        isCompletedList = questionsList.map({ _ in .notStarted })
        quizViewModels = questionsList.map({ QuizViewModel(questions: $0) })
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(questionsList.enumerated()), id: \.element) {
                    index, questions in
                    NavigationLink(
                        destination: {
                            QuizView(
                                viewModel: quizViewModels[index],
                                isCompleted: $isCompletedList[index])
                        },
                        label: {
                            HStack {
                                Spacer()
                                Text("第\(index + 1)セクション")
                                Spacer()
                                Text(isCompletedList[index].description)
                            }
                        }
                    )
                }
            }
            .navigationTitle("問題一覧")
        }
    }
}
