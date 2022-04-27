/*
 See LICENSE folder for this sample’s licensing information.
 */

import AVFoundation
import Foundation
import Speech
import SwiftUI

/// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?
    
    /**
     Initializes a new speech recognizer. If this is the first time you've used the class, it
     requests access to the speech recognizer and the microphone.
     */
    init() {
        recognizer = SFSpeechRecognizer()
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    /**
     Begin transcribing audio.
     
     Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
     The resulting transcription is continuously written to the published `transcript` property.
     */
    func transcribe(correctWord: String){
        
        if audioStatus {
            //nothing to do
        } else {
            //nothing to do
            return
        }
        
        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                
                self.task = recognizer.recognitionTask(with: request) { result, error in
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil
                    
                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                    }
                    
                    if let result = result {
                        self.speak(result.bestTranscription.formattedString)
                        
                        let textoFalado = result.bestTranscription.formattedString
                        
                        let ultimaPalavraFalada = textoFalado.uppercased()
                        
                        print(ultimaPalavraFalada)
                        NotificationCenter.default.post(name: NSNotification.Name("palavras"), object: textoFalado)
                        
                        testIfSpokeCorrectWord(dictateString: ultimaPalavraFalada, correctColor: correctWord.uppercased())
                    }
                }
            } catch {
                self.reset()
                self.speakError(error)
            }
        }
        
        func lose() {
            
        }
        //this function tests if user spoke the correct color
        func testIfSpokeCorrectWord (dictateString: String, correctColor: String) {
            if correctColor.uppercased() == "start".uppercased() {
                
            outerLoop: for start in start {
                if dictateString.contains(start) {
                    self.stopTranscribing()
                    NotificationCenter.default.post(name: NSNotification.Name("startGame"), object: nil)
                    break outerLoop
                }
            }
                
            } else if correctColor.uppercased() == "restart".uppercased() {
                
            outerLoop: for restart in restart {
                if dictateString.contains(restart) {
                    self.stopTranscribing()
                    NotificationCenter.default.post(name: NSNotification.Name("resetGame"), object: nil)
                    break outerLoop
                }
            }
                
            } else {
                
                var allColors = red + green + blue + yellow + orange + white + purple + pink
                
                var arrayColors = ["nil"]
                
                if correctColor.uppercased() == "red".uppercased(){
                    arrayColors = red
                } else if correctColor.uppercased() == "green".uppercased() {
                    arrayColors = green
                } else if correctColor.uppercased() == "blue".uppercased() {
                    arrayColors = blue
                } else if correctColor.uppercased() == "yellow".uppercased() {
                    arrayColors = yellow
                } else if correctColor.uppercased() == "orange".uppercased() {
                    arrayColors = orange
                } else if correctColor.uppercased() == "white".uppercased() {
                    arrayColors = white
                } else if correctColor.uppercased() == "purple".uppercased() {
                    arrayColors = purple
                } else if correctColor.uppercased() == "pink".uppercased() {
                    arrayColors = pink
                }
                
                allColors = Array(Set(allColors).subtracting(arrayColors))
                
            outerLoop: for arrayColor in arrayColors {
                if dictateString.contains(arrayColor) {
                    score = score + 1
                    self.stopTranscribing()
                    NotificationCenter.default.post(name: NSNotification.Name("CorrectWord"), object: nil)
                    break outerLoop
                } else {
                    for allColor in allColors {
                        if dictateString.contains(allColor) {
                            lose()
                            self.stopTranscribing()
                            NotificationCenter.default.post(name: NSNotification.Name("IncorrectWord"), object: nil)
                            break outerLoop
                        } else {
                            //não faz nada pq a falta foi fora de contexto
                        }
                    }
                }
            }
            }
            
        }
    }
    
    /// Stop transcribing audio.
    func stopTranscribing() {
        reset()
    }
    
    /// Reset the speech recognizer.
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func speak(_ message: String) {
        transcript = message
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
