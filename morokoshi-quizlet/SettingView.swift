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
    case quizView(Questions)

}

struct SettingView: View {
    @State private var path: NavigationPath = NavigationPath()
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
                        QuestionListView()
                    case .setting:
                        SettingView()
                    case .quizView(let questions):
                        QuizView(
                            viewModel: QuizViewModel(
                                questions: questions.questions))
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
