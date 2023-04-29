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
