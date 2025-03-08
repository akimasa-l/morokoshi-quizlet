//
//  SettingView.swift
//  morokoshi-quizlet
//
//  Created by 劉明正 on 2025/03/08.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                QuizView()
            } label: {
                Text("Quizに進む")
            }
        }
    }
}
