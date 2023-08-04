//
//  ContentView.swift
//  XSwift-SwiftUIExamples
//
//  Created by Jorge Mattei on 8/4/23.
//

import SwiftUI
import XSwift_SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Shutter Camera",
                               value: Navigation.shutterCamera)
            }
            .navigationTitle("SwiftUI Tools")
            .navigationDestination(for: Navigation.self) { navigation in
                switch navigation {
                case .shutterCamera:
                    Navigation.shutterCamera.view
                }
            }
        }

    }

    enum Navigation: Hashable {
        case shutterCamera
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .shutterCamera:
                ShutterCameraView { image in }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
