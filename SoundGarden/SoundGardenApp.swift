//
//  SoundGardenApp.swift
//  SoundGarden
//
//  Created by Lu on 8/5/26.
//

import SwiftUI

@main
struct SoundGardenApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
