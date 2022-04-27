//
//  File.swift
//  Child Cognitive Development
//
//  Created by Marcelo Diefenbach on 17/04/22.
//

import Foundation
import SwiftUI

struct ScoreView: View {
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @Binding var navigated: Bool
    
    let restartGame = NotificationCenter.default
        .publisher(for: NSNotification.Name("restartGame"))
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            HStack (alignment: .center) {
                VStack (alignment: .center, spacing: 50) {
                    Text("Your score:").multilineTextAlignment(.leading).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.031,nil)!).weight(.bold))
                        .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .center)
                        .foregroundColor(.white)
                    VStack {
                        Text("\(score)").multilineTextAlignment(.leading).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.2,nil)!).weight(.bold))
                            .frame(width: UIScreen.main.bounds.size.width*1, alignment: .center)
                            .foregroundColor(.white)
                    }
                    NavigationLink("", destination: GameView().navigationBarBackButtonHidden(true), isActive: $navigated)
                    RoundedRectangle(cornerRadius: 500)
                        .fill(Color.white)
                        .frame(width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.07, alignment: .center)
                        .overlay(Text("Restart").foregroundColor(Color.black).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.029,nil)!).weight(.regular)))
                        .onTapGesture {
                            NotificationCenter.default.post(name: NSNotification.Name("resetGame"), object: nil)
                            score = 0
                            self.navigated = false
                        }
                        .onAppear(){
                            listenWords()
                        }
                        .onReceive(restartGame) { _ in
                            NotificationCenter.default.post(name: NSNotification.Name("resetGame"), object: nil)
                            self.navigated = false
                        }
                    
                }
            }
        }.navigationBarHidden(true)
    }
    
    func listenWords() {
        speechRecognizer.reset()
        speechRecognizer.transcribe(correctWord: "restart")
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(navigated: .constant(true))
    }
}
