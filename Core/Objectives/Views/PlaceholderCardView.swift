//
//  PlaceholderCardView.swift
//  Focus
//
//  Created by Kasra on 2024-07-20.
//

import Foundation
import SwiftUI

struct PlaceholderCardView: View {
    var body: some View {
        VStack {
            Text("Tap '+' to Add Tasks Here")
                .font(.subheadline)
                .foregroundColor(Color(red: 88/255, green: 88/255, blue: 88/255))
                .padding()
                .padding(.bottom,10)
        }
        .padding(.bottom, 10)
        .padding(.top, 20)
        .background(Color.clear)
    }
}

struct PlaceholderCardView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderCardView()
    }
}
