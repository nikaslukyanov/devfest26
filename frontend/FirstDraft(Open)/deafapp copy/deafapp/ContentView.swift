import SwiftUI

// MARK: - Main App Entry Point

struct SonarApp: View {
    @State private var showingConversation = false
    
    var body: some View {
        if showingConversation {
            ContentView(onEndConversation: {
                showingConversation = false
            })
        } else {
            HomePageView(onStartConversation: {
                showingConversation = true
            })
        }
    }
}

// MARK: - Homepage View

struct HomePageView: View {
    let onStartConversation: () -> Void
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.cyan.opacity(0.4),
                    Color.teal.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon/Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 120, height: 120)
                        .shadow(radius: 20)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                }
                
                // App Title
                Text("Sonar")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.white)
                
                // Description
                VStack(spacing: 12) {
                    Text("Navigate group conversations")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text("Track speakers around you and follow\nthe conversation in real-time")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Start Conversation Button
                Button(action: onStartConversation) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 22))
                        Text("Start Group Conversation")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Models

struct Speaker: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
    var angle: Double // Angle in degrees (0-360) for compass direction
}

struct TranscriptLine: Identifiable {
    let id = UUID()
    let speaker: Speaker
    let text: String
    let timestamp: Date
}

struct ConversationSummary {
    let duration: String
    let keyTopics: [String]
}

// MARK: - Main View

struct ContentView: View {
    let onEndConversation: () -> Void
    
    @State private var speakers: [Speaker] = [
        Speaker(name: "Sarah", color: .blue, angle: 0),
        Speaker(name: "Alex", color: .green, angle: 270),
        Speaker(name: "Mark", color: .orange, angle: 90)
    ]
    
    @State private var currentSpeaker: Speaker?
    @State private var transcriptLines: [TranscriptLine] = []
    @State private var showingAddSpeaker = false
    @State private var showingSummary = false
    @State private var conversationSummary: ConversationSummary?
    
    var body: some View {
        ZStack {
            // Background color changes based on current speaker
            (currentSpeaker?.color.opacity(0.3) ?? Color.gray.opacity(0.2))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
      
                
                // Title and New Person Button
                HStack {
                    Button(action: stopConversation) {
                        Text("Stop Conversation")
                            .foregroundColor(.red)
                            .font(.system(size: 16))
                    }
                    Spacer()
                    
                    Button(action: { showingAddSpeaker = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New Person")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Compass Circle with Speaker
                SpeakerCompassView(
                    speakers: $speakers,
                    currentSpeaker: currentSpeaker
                )
                .frame(height: 300)
                .padding(.bottom, 30)
                
                // Transcript Section
                TranscriptView(transcriptLines: transcriptLines)
            }
            
            // Add Speaker Sheet
            if showingAddSpeaker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingAddSpeaker = false
                    }
                
                AddSpeakerView(
                    isPresented: $showingAddSpeaker,
                    onAddSpeaker: addNewSpeaker
                )
                .transition(.move(edge: .bottom))
            }
            
            // Summary Sheet
            if showingSummary, let summary = conversationSummary {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingSummary = false
                    }
                
                ConversationSummaryView(
                    summary: summary,
                    isPresented: $showingSummary,
                    onEndConversation: onEndConversation
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: currentSpeaker)
        .animation(.easeInOut, value: showingAddSpeaker)
        .animation(.easeInOut, value: showingSummary)
        .onAppear {
            // Simulate conversation for demo
            simulateConversation()
        }
    }
    
    private func addNewSpeaker(name: String) {
        let colors: [Color] = [.purple, .pink, .cyan, .yellow, .mint, .indigo]
        let usedColors = Set(speakers.map { $0.color })
        let availableColor = colors.first { !usedColors.contains($0) } ?? .gray
        
        let newSpeaker = Speaker(name: name, color: availableColor, angle: 180)
        speakers.append(newSpeaker)
        showingAddSpeaker = false
    }
    
    private func stopConversation() {
        // Generate summary
        conversationSummary = ConversationSummary(
            duration: "45 mins",
            keyTopics: [
                "Discussed upcoming project milestones.",
                "Mark raised concerns about resources.",
                "Sarah proposed a new timeline.",
                "Alex joined and introduced himself."
            ]
        )
        showingSummary = true
    }
    
    private func simulateConversation() {
        // Demo data matching the image
        let demoLines = [
            (speakers[1], "What about the timeline?"),
            (speakers[0], "So, the plan for the project is to..."),
            (speakers[2], "I agree, but we need to consider...")
        ]
        
        for (index, line) in demoLines.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                transcriptLines.append(TranscriptLine(
                    speaker: line.0,
                    text: line.1,
                    timestamp: Date()
                ))
                currentSpeaker = line.0
            }
        }
    }
}

// MARK: - Speaker Compass View

struct SpeakerCompassView: View {
    @Binding var speakers: [Speaker]
    let currentSpeaker: Speaker?
    
    var body: some View {
        GeometryReader { geometry in
            let radius: CGFloat = 100
            
            ZStack {
                // Outer rings
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: radius * 2.6, height: radius * 2.6)
                
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: radius * 2.3, height: radius * 2.3)
                
                // Speaker indicators around the circle
                ForEach(speakers) { speaker in
                    SpeakerIndicator(
                        speaker: speaker,
                        isActive: currentSpeaker?.id == speaker.id,
                        radius: radius * 1.3,
                        onDrag: { newAngle in
                            if let index = speakers.firstIndex(where: { $0.id == speaker.id }) {
                                speakers[index].angle = newAngle
                            }
                        }
                    )
                }
                
                // Center circle with current speaker name
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: radius * 2, height: radius * 2)
                        .shadow(radius: 10)
                    
                    if let current = currentSpeaker {
                        Text(current.name)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Speaker Indicator

struct SpeakerIndicator: View {
    let speaker: Speaker
    let isActive: Bool
    let radius: CGFloat
    let onDrag: (Double) -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            let angleInRadians = speaker.angle * .pi / 180
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let x = centerX + radius * cos(angleInRadians - .pi / 2)
            let y = centerY + radius * sin(angleInRadians - .pi / 2)
            
            ZStack {
                // Arrow pointing to speaker
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: isActive ? 32 : 24))
                    .foregroundColor(speaker.color)
                    .rotationEffect(.degrees(speaker.angle))
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: isActive)
            }
            .position(x: x, y: y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let centerX = geometry.size.width / 2
                        let centerY = geometry.size.height / 2
                        let vector = CGPoint(x: value.location.x - centerX, y: value.location.y - centerY)
                        var angle = atan2(vector.y, vector.x) * 180 / .pi + 90
                        if angle < 0 { angle += 360 }
                        onDrag(angle)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }
}

// MARK: - Transcript View

struct TranscriptView: View {
    let transcriptLines: [TranscriptLine]
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(transcriptLines) { line in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(line.speaker.name) (\(line.speaker.color.description.capitalized)):")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(line.speaker.color)
                                
                                Text(line.text)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                            .id(line.id)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: transcriptLines.count) { oldValue, newValue in
                    if let lastLine = transcriptLines.last {
                        withAnimation {
                            proxy.scrollTo(lastLine.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Color.white.opacity(0.5))
    }
}

// MARK: - Add Speaker View

struct AddSpeakerView: View {
    @Binding var isPresented: Bool
    let onAddSpeaker: (String) -> Void
    
    @State private var newSpeakerName = ""
    @State private var isListening = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add New Speaker")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            
            Text("Ask the new person to say the phrase below to calibrate their voice.")
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.blue)
                    
                    Text("Hi, my name is Alex, and I'm joining the conversation.")
                        .font(.system(size: 16))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Audio waveform visualization
                if isListening {
                    AudioWaveform()
                        .frame(height: 60)
                    
                    Text("Listening...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                isListening.toggle()
                if !isListening && !newSpeakerName.isEmpty {
                    onAddSpeaker(newSpeakerName)
                } else {
                    // Simulate voice capture - in real app, this would use speech recognition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        newSpeakerName = "Alex"
                        isListening = false
                    }
                }
            }) {
                Text(isListening ? "Stop" : "Add \(newSpeakerName.isEmpty ? "Speaker" : newSpeakerName)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isListening ? Color.red : Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

// MARK: - Audio Waveform

struct AudioWaveform: View {
    @State private var amplitudes: [CGFloat] = Array(repeating: 0.3, count: 50)
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<amplitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray)
                    .frame(width: 3, height: amplitudes[index] * 60)
            }
        }
        .onAppear {
            animateWaveform()
        }
    }
    
    private func animateWaveform() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                for i in 0..<amplitudes.count {
                    amplitudes[i] = CGFloat.random(in: 0.2...1.0)
                }
            }
        }
    }
}

// MARK: - Conversation Summary View

struct ConversationSummaryView: View {
    let summary: ConversationSummary
    @Binding var isPresented: Bool
    let onEndConversation: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    isPresented = false
                    onEndConversation()
                }) {
                    Text("Done")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Conversation Summary")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Color.clear.frame(width: 50)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Today, 10:30 AM • \(summary.duration)")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("Key Topics")
                    .font(.system(size: 18, weight: .semibold))
                
                ForEach(summary.keyTopics, id: \.self) { topic in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(topic)
                    }
                    .font(.system(size: 16))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {}) {
                    Text("View Full Transcript")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {}) {
                    Text("Export Summary")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    SonarApp()
}
