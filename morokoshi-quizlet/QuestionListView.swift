//
//  QuestionListView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/03/08.
//

import Algorithms
import SwiftUI

struct Questions: Hashable, Identifiable, Equatable {
    let id = UUID()
    var questions: [Question]
    var isCompleted = QuestionStatus.notStarted
    static func == (lhs: Questions, rhs: Questions) -> Bool {
        return lhs.id == rhs.id
    }
}

struct QuestionListView: View {
    @State var questionsList: [Questions] = [
        Questions(questions: [
            Question(
                questionText: "1問目：Swiftの変数を宣言するキーワードは？",
                choices: ["var", "let", "const", "def"], correctAnswer: "var")
        ]),
        Questions(questions: [
            Question(
                questionText: "2問目",
                choices: ["2問目", "let", "const", "def"], correctAnswer: "2問目")
        ]),
        Questions(questions: [
            Question(
                questionText: "Swiftの変数を宣言するキーワードは？",
                choices: ["var", "let", "const", "def"], correctAnswer: "var")
            //            Question(
            //                questionText: "Swiftで定数を宣言するキーワードは？",
            //                choices: ["var", "let", "static", "const"], correctAnswer: "let"
            //            ),
            //            Question(
            //                questionText: "Swiftのプロトコルは何を定義するためのものですか？？", choices: [],
            //                correctAnswer: "仕様や契約"),
        ]),
    ]
    //    @State var presentedList: [Bool]=[false,false,false,false,false]
    //    var quizViewModels: [QuizViewModel]
    //    init() {
    //        isCompletedList = questionsList.map({ _ in return .notStarted })
    //        quizViewModels = questionsList.map({
    //            return QuizViewModel(questions: $0.questions)
    //        })
    //        //        presentedList = questionsList.map({ _ in return false }) + [false]
    //    }
    var body: some View {
        List {
            ForEach(questionsList.indexed(), id: \.element) {
                 index,questions in
                NavigationLink(
                    value: NavigationPathEnum.quizView(questions),
                    label: {
                        HStack {
                            Text("")
                            Spacer()
                            Text("第\(index + 1)セクション")
                            Spacer()
                            Text(questions.isCompleted.description)
                        }
                    })
            }
        }
        .navigationTitle("問題一覧")
    }
}
