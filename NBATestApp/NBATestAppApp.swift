//
//  NBATestAppApp.swift
//  NBATestApp
//
//  Created by Sanjay Mali on 23/08/25.
//

import SwiftUI

@main
struct NBATestAppApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .onAppear {
                            // Hide splash after animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    ContentView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }
}
