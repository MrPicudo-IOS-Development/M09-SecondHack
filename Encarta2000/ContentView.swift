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
