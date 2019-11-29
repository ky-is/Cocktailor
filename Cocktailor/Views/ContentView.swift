import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			MyBar()
				.tabItem {
					Image(systemName: "squares.below.rectangle")
					Text("My Bar")
				}
			Build()
				.tabItem {
					Image(systemName: "wand.and.stars")
					Text("Build")
				}
			Explore()
				.tabItem {
					Image(systemName: "eyeglasses")
					Text("Explore")
				}
		}
			.accentColor(.primary)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
