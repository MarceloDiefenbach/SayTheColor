//
//  GameView.swift
//  SayTheColor
//
//  Created by Marcelo Diefenbach on 25/04/22.
//

import SwiftUI

struct GameView: View {
    
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
    func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        return CGFloat(level * 2) // scaled to max at 300 (our height of our bar)
    }
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State var opacidade = opacidadeGlobal
    @State var word = "green"
    @State var colorName = "red"
    @State var color: Color = .red
    @State var navigated = false
    @State var palavra = ""
    @State var internTitleAlert = titleAlert
    @State var internSymbolAlert = symbolAlert
    
    let correctWord = NotificationCenter.default
        .publisher(for: NSNotification.Name("CorrectWord"))
    let incorrectWord = NotificationCenter.default
        .publisher(for: NSNotification.Name("IncorrectWord"))
    let resetGame = NotificationCenter.default
        .publisher(for: NSNotification.Name("resetGame"))
    let palavras = NotificationCenter.default
        .publisher(for: NSNotification.Name("palavras"))
    
    var body: some View {
        ZStack{
            VStack{
                Rectangle().foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.3, alignment: .center)
                    .overlay(){
                        Text("\(score) points").font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.06,nil)!).weight(.bold))
                            .foregroundColor(.white)
                    }
                Spacer()
            }
            VStack{
                Text(word.lowercased()).multilineTextAlignment(.center).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.width*0.2,nil)!).weight(.bold))
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.2, alignment: .center)
                    .foregroundColor(color)
                    .padding(.top, UIScreen.main.bounds.size.height*0.02)
                    .onAppear(){
                        listenWords()
                        score = 0
                    }
                    .onReceive(correctWord){ _ in
                        changeColor()
                        listenWords()
                    }
                    .onReceive(incorrectWord){ _ in
                        changeColor()
                        self.navigated = true
                    }
                    .onReceive(resetGame) { _ in
                        changeColor()
                        score = 0
                    }
                    .onReceive(palavras) { palavra in
                        self.palavra = palavra.object as! String
                    }
                Text("Say the name of color to earn a point").font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.014,nil)!).weight(.regular))
                    .foregroundColor(.white)
            }
            NavigationLink("", destination: ScoreView(navigated: $navigated).navigationBarBackButtonHidden(true), isActive: $navigated)
            VStack{
                Spacer()
                HStack (alignment: .center, spacing: 10){
                    RoundedRectangle(cornerRadius: 500)
                        .frame(width: UIScreen.main.bounds.height*0.05, height: UIScreen.main.bounds.height*0.05, alignment: .center)
                        .foregroundColor(.white)
                        .overlay(
                            HStack (spacing: 20){
                                Image(systemName: internSymbolAlert)
                                    .font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.015,nil)!).weight(.regular))
                                    .foregroundColor(.black)
                            }
                        )
                        .onTapGesture {
                            if audioStatus {
                                symbolAlert = "mic.slash.fill"
                                titleAlert = "Click to activate microphone"
                                internSymbolAlert = "mic.slash.fill"
                                internTitleAlert = "Click to activate microphone"
                                audioStatus = false
                                speechRecognizer.reset()
                                opacidade = 0.0
                                opacidadeGlobal = 0.0
                            } else {
                                symbolAlert = "mic.fill"
                                titleAlert = "Click to disable microphone"
                                internSymbolAlert = "mic.fill"
                                internTitleAlert = "Click to disable microphone"
                                audioStatus = true
                                listenWords()
                                opacidade = 1.0
                                opacidadeGlobal = 1.0
                            }
                        }
                    if opacidade == 1.0 {
                        HStack(alignment: .center, spacing: 5) {
                            ForEach(mic.soundSamples, id: \.self) { level in
                                BarView(value: self.normalizeSoundLevel(level: level))
                            }
                        }.opacity(opacidade)
                    }
                }.padding(.bottom, UIScreen.main.bounds.size.height*0.05)
            }
        }.ignoresSafeArea()
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
            .background(Color.black)
            .navigationBarHidden(true)
    }
    
    func listenWords() {
        speechRecognizer.reset()
        speechRecognizer.transcribe(correctWord: colorName)
    }
    
    func changeColor() {
        let quantity = colorNames.count
        let newWord = Int.random(in: 0..<quantity)
        word = colorNames[newWord]
        
        let quantity2 = colorNames.count
        let newWord2 = Int.random(in: 0..<quantity2)
        color = colors[newWord2]
        
        switch newWord2 {
        case 0:
            colorName = "red"
        case 1:
            colorName = "Green"
        case 2:
            colorName = "Blue"
        case 3:
            colorName = "Yellow"
        case 4:
            colorName = "Orange"
        case 5:
            colorName = "white"
        case 6:
            colorName = "purple"
        case 7:
            colorName = "pink"
        default:
            colorName = "White"
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

let numberOfSamples: Int = 4

struct BarView: View {
    
    var value: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(width: 2, height: value)
    }
}
