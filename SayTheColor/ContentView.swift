//
//  ContentView.swift
//  SayTheColor
//
//  Created by Marcelo Diefenbach on 25/04/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State var navigated = false
    
    @State var internTitleAlert = titleAlert
    @State var internSymbolAlert = symbolAlert
    @State var opacidade2 = opacidadeGlobal
    
    let startGame = NotificationCenter.default
        .publisher(for: NSNotification.Name("startGame"))
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.black.ignoresSafeArea()
                HStack (alignment: .center){
                    VStack (alignment: .leading, spacing: 50){
                        Text("This game was created to assist in the cognitive development of children and adolescents but it can also be used for adults to exercise the brain.").multilineTextAlignment(.leading).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.029,nil)!).weight(.regular))
                            .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
                            .foregroundColor(.white)
                        Text("Feel challenged to get as many hits as you can.").multilineTextAlignment(.leading).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.029,nil)!).weight(.bold))
                            .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
                            .foregroundColor(.white)
                            .onAppear(){
                                listenWords()
                                score = 0
                            }
                            .onReceive(startGame){ _ in
                                self.navigated = true
                            }
                        Text("You can use the app hands-free. Say start and the game will start!").multilineTextAlignment(.leading).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.02,nil)!).weight(.regular))
                            .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
                            .foregroundColor(.white)
                        
                        NavigationLink("", destination: GameView().navigationBarBackButtonHidden(true), isActive: $navigated)

                        NavigationLink(destination: GameView().navigationBarBackButtonHidden(true)) {
                            RoundedRectangle(cornerRadius: 500)
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.07, alignment: .center)
                                .overlay(Text("Start").foregroundColor(Color.black).font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.029,nil)!).weight(.regular)))
                        }
                    }
                }
                VStack (alignment: .trailing){
                    Spacer()
                    HStack (alignment: .center, spacing: 10){
                        Spacer()
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
                                    opacidade2 = 0.0
                                    opacidadeGlobal = 0.0
                                } else {
                                    symbolAlert = "mic.fill"
                                    titleAlert = "Click to disable microphone"
                                    internSymbolAlert = "mic.fill"
                                    internTitleAlert = "Click to disable microphone"
                                    audioStatus = true
                                    listenWords()
                                    opacidade2 = 1.0
                                    opacidadeGlobal = 1.0
                                }
                            }
                    }.padding(.bottom, UIScreen.main.bounds.size.height*0.05)
                }.padding(.trailing, UIScreen.main.bounds.size.height*0.05)
            }.navigationBarHidden(true)
        }.navigationViewStyle(.stack)
            .preferredColorScheme(.dark)
    }
    
    func listenWords() {
        speechRecognizer.reset()
        speechRecognizer.transcribe(correctWord: "start")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
