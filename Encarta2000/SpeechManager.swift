/* SpeechManager.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import Foundation
import Speech
import AVFoundation

// Creamos la clase SpeechManager que hereda de NSObject y se ajusta a los protocolos ObservableObject y SFSpeechRecognizerDelegate.
class SpeechManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    
    // Inicializamos un reconocedor de voz para el idioma español.
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
    // Definimos variables para la solicitud de reconocimiento, la tarea de reconocimiento y el motor de audio.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    // Función para solicitar autorización para el reconocimiento de voz.
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Autorizado")
                case .denied, .restricted, .notDetermined:
                    print("No autorizado")
                default:
                    print("No hay más casos, pero pueden agregarse en el futuro")
                }
            }
        }
    }
    
    // Función para comenzar la grabación y el reconocimiento de voz.
    func startRecording() throws {
        // Cancelamos cualquier tarea de reconocimiento en curso.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configuramos la sesión de audio para grabar y medir el audio.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Obtenemos el nodo de entrada de audio del motor de audio.
        let inputNode = audioEngine.inputNode
        
        // Inicializamos una solicitud de reconocimiento de audio.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Comprobamos si se creó correctamente la solicitud de reconocimiento.
        guard let recognitionRequest = recognitionRequest else {
            fatalError("No se pudo crear el objeto SFSpeechAudioBufferRecognitionRequest")
        }
        
        // Establecemos que la solicitud de reconocimiento no informe resultados parciales.
        recognitionRequest.shouldReportPartialResults = false
        
        // Iniciamos una tarea de reconocimiento con el reconocedor de voz y la solicitud de reconocimiento.
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            // Procesamos los resultados de la tarea de reconocimiento, si los hay.
            if let result = result {
                let recognizedVoiceText = result.bestTranscription.formattedString
                print(recognizedVoiceText)
                isFinal = result.isFinal
                
                // Ejecutamos acciones específicas según el texto reconocido.
                switch recognizedVoiceText {
                case "Reproduce el sonido":
                    print("Reproduciendo...")
                case "Detener la reproducción":
                    print("La reproducción se ha detenido")
                case "Suma dos números", "Suma los números":
                    print("Sumando números...")
                default:
                    print("Hola mucho gusto, soy el señor salchicha")
                }
            }
            
            // Si hay un error o si el resultado es final, detenemos el motor de audio y limpiamos los recursos.
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        // Establecemos un "tap" en el nodo de entrada de audio para procesar el audio entrante.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Preparamos y comenzamos el motor de audio.
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // Función que se llama cuando se toca el botón de grabación.
    func recordButtonTapped() {
        // Si el motor de audio está en funcionamiento, lo detenemos y finalizamos la solicitud de reconocimiento.
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            // Si el motor de audio no está en funcionamiento, intentamos iniciar la grabación.
            do {
                try startRecording()
            } catch {
                print("No se pudo iniciar la grabación")
            }
        }
    }
}
