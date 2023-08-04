//
//  ShutterButtonStyle.swift
//  XSwift-SwiftUIExamples
//
//  Created by Jorge Mattei on 8/3/23.
//

import SwiftUI

public struct ShutterButtonStyle: ButtonStyle {

    init() { }

    public func makeBody(configuration: Configuration) -> some View {
        Circle()
            .frame(width: 100, height: 100, alignment: .bottom)
            .foregroundColor(Color.white)
            .padding(2)
            .overlay {
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(.white)
            }
            .shadow(radius: 5)
    }
}

struct ShutterButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("") {

        }
        .buttonStyle(ShutterButtonStyle())
    }
}
