/* *** *** *** REFERENCE *** *** *** */

/*

/* ContentView.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import SwiftUI

struct ContentView: View {
    
    @StateObject private var sharedText = SharedInfoModel()
    
    var body: some View {
        NavigationView {
            TabView {
                NavigationLink(destination: TextView()) {
                    Text("Text recognition")
                }
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Proyecto 1")
                }
                
                NavigationLink(destination: SpeechView()) {
                    Text("Speech recognition")
                }
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Proyecto 2")
                }
                
                NavigationLink(destination: GPTView()) {
                    Text("GPT API")
                }
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Proyecto 3")
                }
            }
        }
        .environmentObject(sharedText)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



/* SharedInfoModel.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import Combine
import SwiftUI

/// Almacena todas las variables observables que necesitamos
class SharedInfoModel: ObservableObject {
    
    @Published var sharedText: String = ""
}




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




/* SpeechView.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import SwiftUI

struct SpeechView: View {
    
    // Definimos una variable de estado para almacenar y actualizar el estado de la grabación.
    @State private var recordingStatus = "Presione el botón para iniciar la grabación"
    // Definimos una variable de estado para almacenar y actualizar el título del botón de grabación.
    @State private var recordButtonTitle = "Iniciar grabación"
    // Definimos una variable de estado para crear un objeto de SpeechManager y mantenerlo actualizado.
    @StateObject private var speechManager = SpeechManager()
    
    var body: some View {
        
        VStack {
            // Mostramos el texto del estado de la grabación y aplicamos un relleno alrededor.
            Text(recordingStatus)
                .padding()
            
            // Creamos un botón que llame a la función recordButtonTapped() de SpeechManager.
            Button{
                speechManager.recordButtonTapped()
                // Comprobamos si el motor de audio está en funcionamiento.
                if speechManager.audioEngine.isRunning {
                    // Si está funcionando, actualizamos el título del botón y el estado de la grabación.
                    recordButtonTitle = "Detener grabación"
                    recordingStatus = "Grabando..."
                } else {
                    // Si no está funcionando, actualizamos el título del botón y el estado de la grabación.
                    recordButtonTitle = "Iniciar grabación"
                    recordingStatus = "Audio analizado."
                }
            } label: {
                // Mostramos el título del botón de grabación y aplicamos un relleno alrededor.
                Text(recordButtonTitle)
                    .padding()
            }
        }
        // Cuando aparece la vista, llamamos a la función requestAuthorization() de SpeechManager para solicitar autorización.
        .onAppear(perform: {
            speechManager.requestAuthorization()
        })
        
    }
}

struct SpeechView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechView()
    }
}



/* GPTView.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

// Importamos las bibliotecas necesarias para la interfaz de usuario y la programación reactiva
import SwiftUI
import Combine

struct GPTView: View {
    
    // Declaramos las propiedades de estado para almacenar la entrada del usuario, la respuesta de GPT y el objeto cancelable
    @State private var userInput = ""
    @State private var gptResponse = ""
    @State private var cancellable: AnyCancellable?
    
    // Creamos una instancia de GPTAPIManager para manejar las solicitudes a la API
    private let gptAPIManager = GPTAPIManager()
    
    // Definimos la vista de contenido usando SwiftUI
    var body: some View {
        // Usamos VStack para organizar los elementos de la vista verticalmente
        VStack {
            // Creamos un campo de texto para que el usuario ingrese su pregunta
            TextField("Ingrese su pregunta aquí", text: $userInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Creamos un botón para enviar la solicitud a la API de GPT
            Button(action: {
                // Llamamos a la función sendGPTRequest cuando se presiona el botón
                sendGPTRequest()
            }) {
                // Establecemos el estilo y la apariencia del botón
                Text("Enviar")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
            }.padding()
            
            // Mostramos la respuesta de GPT en un cuadro de texto
            Text(gptResponse)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }.padding()
    }
    
    // Definimos una función privada para enviar una solicitud a la API de GPT
    private func sendGPTRequest() {
        // Cancelamos cualquier solicitud anterior que pueda estar en curso
        cancellable?.cancel()
        
        // Creamos un prompt modificado que incluye la entrada del usuario
        let modifiedUserInput = userInput + ". Limita tu respuesta a 50 palabras o menos"
        
        // Enviamos una solicitud a la API de GPT y manejamos el resultado usando Combine
        cancellable = gptAPIManager.sendRequest(prompt: modifiedUserInput)
            .sink(receiveCompletion: { completion in
                // Manejamos los casos de éxito y fracaso en la recepción de la respuesta
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { response in
                // Actualizamos la propiedad gptResponse con la respuesta recibida de la API
                gptResponse = response
                print("Respuesta GPT: \(response)")
            })
    }
    
    
}

struct GPTView_Previews: PreviewProvider {
    static var previews: some View {
        GPTView()
    }
}




/* GPTAPIMaganer.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

// Importamos las bibliotecas necesarias para trabajar con Foundation y Combine
import Foundation
import Combine

// Definimos una clase GPTAPIManager para manejar las solicitudes a la API de GPT
class GPTAPIManager {
    // Declaramos la clave API y la URL de la API de GPT como constantes privadas
    private let apiKey = "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"
    private let gptURL = "https://api.openai.com/v1/chat/completions"
    
    // Definimos una función sendRequest que toma una cadena de texto como entrada y devuelve un Publisher
    func sendRequest(prompt: String) -> AnyPublisher<String, Error> {
        // Verificamos que la URL sea válida
        guard let url = URL(string: gptURL) else {
            fatalError("Invalid URL")
        }
        
        // Creamos una solicitud HTTP POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Definimos el cuerpo de la solicitud como un diccionario y lo convertimos a datos JSON
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "Estás hablando con un asistente de inteligencia artificial. ¿En qué puedo ayudarte hoy?"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": NSNumber(value: 150)
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            fatalError("Error encoding JSON")
        }
        
        // Usamos URLSession para enviar la solicitud y manejar la respuesta usando Combine
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                // Verificamos que la respuesta sea válida y tenga un código de estado 200
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode != 200 {
                    print("Status Code: \(httpResponse.statusCode)")
                    print("Response: \(String(data: data, encoding: .utf8) ?? "No data")")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // Decodificamos la respuesta JSON en una instancia de GPTAPIResponse
            .decode(type: GPTAPIResponse.self, decoder: JSONDecoder())
            // Extraemos el contenido del mensaje de la primera opción en la respuesta
            .map { $0.choices[0].message.content }
            // Nos aseguramos de recibir la respuesta en el hilo principal
            .receive(on: DispatchQueue.main)
            // Convertimos el resultado en un Publisher genérico
            .eraseToAnyPublisher()
    }
}

// Definimos las estructuras necesarias para decodificar la respuesta JSON
struct GPTAPIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        let index: Int
        let logprobs: JSONNull?
        let finish_reason: String
        
        // Definimos una estructura anidada Message para almacenar la información del mensaje
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
}

// Definimos una estructura JSONNull para manejar valores nulos en la respuesta JSON
struct JSONNull: Codable {
    init(from decoder: Decoder) throws {}
    func encode(to encoder: Encoder) throws {}
}




/* CameraViewModelTR.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import SwiftUI
import UIKit
import AVFoundation
import Vision

class CameraViewModelTR: NSObject, ObservableObject {
    
    // @EnvironmentObject var speechManager: SpeechManager
    
    /// Variables que se pueden utilizar en varias vistas gracias a que la clase es de tipo ObservableObject
    @Published var image: UIImage?
    @Published var isPresentingImagePicker = false
    @Published var recognizedText: String?
    @Published var matchStatus = false
    
    // Cadena de comparación de texto.
    private let referenceText = "Valclan"
    
    func captureImage() {
        isPresentingImagePicker = true
    }

    func imagePickerCompletionHandler(image: UIImage?) {
        self.image = image
        isPresentingImagePicker = false
        
        if let image = image {
            recognizeTextInImage(image)
        }
    }

    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to convert UIImage to CGImage.")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error recognizing text: \(error)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")

            DispatchQueue.main.async {
                self.recognizedText = recognizedText
                self.matchStatus = recognizedText == self.referenceText
            }
        }

        request.recognitionLevel = .accurate
        let requests = [request]

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform(requests)
        }
    }
}




/* ImagePickerTR.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import SwiftUI

struct ImagePickerTR: UIViewControllerRepresentable {
    
    let sourceType: UIImagePickerController.SourceType
    let completionHandler: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let completionHandler: (UIImage?) -> Void

        init(completionHandler: @escaping (UIImage?) -> Void) {
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            completionHandler(image)
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil)
            picker.dismiss(animated: true)
        }
    }
}




/* SpeechSintext.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import Foundation
import AVFoundation

/// Clase de tipo "ObservableObject" que permite tener un objeto que lee texto en voz alta dentro de una vista.
class SpeechSintex: ObservableObject {
    // Objeto que nos permite leer en voz alta un texto de la aplicación
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String) {
        // Convertimos el texto a un formato que puede leer el sintetizador.
        let speechUtterance = AVSpeechUtterance(string: text)
        /// Configuramos el idioma del sintetizador y la velocidad de locución.
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        speechUtterance.rate = 0.55
        // Hacemos que se lea el texto.
        speechSynthesizer.speak(speechUtterance)
    }
}




/* TextView.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import SwiftUI
import AVFoundation

struct TextView: View {
    
    // Variable de estado, se declara por primera vez aquí.
    @StateObject private var cameraViewModel = CameraViewModelTR()
    @StateObject private var speeaches = SpeechSintex()
    
    // Variable para recrear la vista cada vez que se presiona el botón de reinicio
    @State private var recreateView = UUID()
    
    /// El cuerpo de la vista principal contiene una etiqueta o bien, la imagen tomada, un botón de tomar fotografía y las etiquetas del texto detectado.
    var body: some View {
        VStack {
            /// Si no se ha capturado ninguna imagen con la cámara, entonces se muestra el texto de instrucciones y el botón para tomar la fotografía
            if cameraViewModel.image != nil {
                // Imagen tomada por la cámara
                Image(uiImage: cameraViewModel.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                // Botón de reinicio
                Button {
                    // Reiniciamos los valores obtenidos del análisis anterior.
                    cameraViewModel.image = nil
                    cameraViewModel.recognizedText = ""
                    recreateView = UUID()
                } label: {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.black)
                        .frame(width: 50)
                }.padding()
                //
            } else {
                Text("Por favor, presiona el botón de la cámara para verificar tu medicina.")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(20)
                Button {
                    cameraViewModel.captureImage()
                } label: {
                    Image(systemName: "camera")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.black)
                        .frame(width: 150)
                        .padding(30)
                }.padding()
            }
            // Texto que se va a leer.
            if let recognizedText = cameraViewModel.recognizedText {
                if cameraViewModel.image != nil {
                    Text("Medicamento: \(recognizedText)")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .onAppear {
                            speeaches.speak(recognizedText)
                        }
                }
            }
            //Text(cameraViewModel.matchStatus ? "¡Si es tu medicina!" : "")
        }
        .sheet(isPresented: $cameraViewModel.isPresentingImagePicker) {
            ImagePickerTR(sourceType: .camera, completionHandler: cameraViewModel.imagePickerCompletionHandler)
        }
        .id(recreateView) // Asociamos el identificador único a la vista principal, para que se vuelva a construir la vista cada vez que se actualice el identificador.
        //.environmentObject(speeaches) // Agregamos la variable de ambiente a la hoja.
        
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
    }
}


*/
