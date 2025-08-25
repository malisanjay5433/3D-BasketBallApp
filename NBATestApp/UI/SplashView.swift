import SwiftUI

struct SplashView: View {
    @State private var ballOffset: CGFloat = -200
    @State private var ballScale: CGFloat = 0.5
    @State private var hoopRotation: Double = 0
    @State private var textOpacity: Double = 0
    @State private var isAnimating = false
    @State private var showMainContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.4),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if !showMainContent {
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Basketball hoop
                    ZStack {
                        // Hoop ring
                        Circle()
                            .stroke(Color.orange, lineWidth: 8)
                            .frame(width: 120, height: 120)
                            .rotation3DEffect(.degrees(hoopRotation), axis: (x: 0, y: 0, z: 1))
                        
                        // Net
                        VStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 100 - CGFloat(index * 8), height: 2)
                                    .offset(y: CGFloat(index * 8))
                            }
                        }
                        .offset(y: 60)
                        
                        // Basketball
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 50, height: 50)
                            .overlay(
                                // Basketball lines
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 50, height: 2)
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 2, height: 50)
                                }
                            )
                            .offset(y: ballOffset)
                            .scaleEffect(ballScale)
                    }
                    
                    // App title
                    VStack(spacing: 10) {
                        Text("NBA")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("3D Shot Chart")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(textOpacity)
                    
                    // Loading indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 12, height: 12)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .opacity(textOpacity)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start the animation sequence
        withAnimation(.easeOut(duration: 1.5)) {
            ballOffset = 0
            ballScale = 1.0
        }
        
        // Rotate the hoop
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            hoopRotation = 360
        }
        
        // Bounce the ball
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            ballOffset = -20
        }
        
        // Scale the ball
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            ballScale = 1.1
        }
        
        // Fade in text and loading
        withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
            textOpacity = 1.0
        }
        
        // Start loading animation
        withAnimation(.easeInOut(duration: 0.5).delay(1.0)) {
            isAnimating = true
        }
        
        // Show main content after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showMainContent = true
            }
        }
    }
}

#Preview {
    SplashView()
}
