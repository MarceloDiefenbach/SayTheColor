//
//  AlertMic.swift
//  Child Cognitive Development
//
//  Created by Marcelo Diefenbach on 20/04/22.
//

import SwiftUI

struct AlertMic: View {
    
    @State var type: Bool
    
    var body: some View {
        if type == true {
            VStack{
                Spacer()
                RoundedRectangle(cornerRadius: 40)
                    .frame(width: UIScreen.main.bounds.width*0.7, height: 100, alignment: .center)
                    .foregroundColor(.white)
                    .overlay(
                        HStack (spacing: 20){
                            Image(systemName: "mic.fill")
                                .font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.024,nil)!).weight(.regular))
                                .foregroundColor(.black)
                            
                            Text("Your microphone is enabled, click here to disable")
                                .font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.02,nil)!).weight(.regular))
                                .foregroundColor(.black)
                        }
                    )
                    .padding(.bottom, UIScreen.main.bounds.size.height*0.06)
            }
        } else {
            VStack{
                Spacer()
                RoundedRectangle(cornerRadius: 40)
                    .frame(width: UIScreen.main.bounds.width*0.7, height: 100, alignment: .center)
                    .foregroundColor(.white)
                    .overlay(
                        HStack (spacing: 20){
                            Image(systemName: "mic.slash.fill")
                                .font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.024,nil)!).weight(.regular))
                                .foregroundColor(.black)
                            
                            Text("Click here to activate the microphone and resume playing")
                                .font(Font(CTFontCreateUIFontForLanguage(.system, UIScreen.main.bounds.size.height*0.02,nil)!).weight(.regular))
                                .foregroundColor(.black)
                        }
                    )
                    .padding(.bottom, UIScreen.main.bounds.size.height*0.06)
            }
        }
    }
}

struct AlertMic_Previews: PreviewProvider {
    static var previews: some View {
        AlertMic(type: true)
    }
}
