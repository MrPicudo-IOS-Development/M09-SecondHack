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
