//
//  CaptureConfirmationView.swift
//  XSwift-SwiftUIExamples
//
//  Created by Jorge Mattei on 8/4/23.
//

import SwiftUI

struct CaptureConfirmationView: View {

    let image: UIImage
    @Environment(\.dismiss) var dismiss
    var onConfirmation: (_ image: UIImage)->()

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .shadow(radius: 5)
                Spacer()
                Button("Done") { onConfirmation(image) }
                    .buttonStyle(.borderedProminent)
                    .shadow(radius: 5)
            }
            .padding()
            .tint(.white)
            .foregroundColor(.black)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, alignment: .center)
                .ignoresSafeArea()
        }
        .background(Color.black)
    }
}

struct CaptureConfirmation_Previews: PreviewProvider {
    static var previews: some View {
        CaptureConfirmationView(image: UIImage(named: "TestImage")!) { image in
        }
    }
}
