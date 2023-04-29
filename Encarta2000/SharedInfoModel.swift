/* SharedInfoModel.swift --> Encarta2000. Created by Miguel Torres on 29/04/23. */

import Combine
import SwiftUI

/// Almacena todas las variables observables que necesitamos
class SharedInfoModel: ObservableObject {
    
    @Published var sharedText: String = ""
}
