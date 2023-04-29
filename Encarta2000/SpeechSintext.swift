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
