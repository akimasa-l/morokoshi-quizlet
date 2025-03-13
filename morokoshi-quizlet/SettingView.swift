//
//  SettingView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/03/08.
//

import SwiftUI

enum NavigationPathEnum: Hashable {
    case questionList
    case setting
    case quizView(Questions, index: Int)

}

struct SettingView: View {
    @State var path: NavigationPath = NavigationPath()
    @State var currentQuestionsIndex: Int = 0
    @State var isQuestionsFinished: Bool = false
    var body: some View {
        NavigationStack(path: $path) {
            NavigationLink(
                value: NavigationPathEnum.questionList,
                label: {
                    Text("Quizに進む")
                }
            )
            .navigationDestination(
                for: NavigationPathEnum.self,
                destination: {
                    destination in
                    switch destination {
                    case .questionList:
                        QuestionListView(
                            currentQuestionsIndex: $currentQuestionsIndex,
                            isQuestionsFinished: $isQuestionsFinished,
                            path: $path
                        )
                    case .setting:
                        SettingView()
                    case .quizView(let questions, let index):
                        QuizView(
                            viewModel: QuizViewModel(
                                questions: questions.questions),
                            path: $path,
                            isQuestionsFinished: $isQuestionsFinished
                        )
                        .onAppear {
                            currentQuestionsIndex = index
                        }
                    }
                }
            )
        }

        //        List{
        //            NavigationLink (
        //                destination:{ QuestionListView()},
        //             label: {
        //                Text("内部に入ると？")
        //            })
        //        }
        //        QuestionListView()
    }
}
