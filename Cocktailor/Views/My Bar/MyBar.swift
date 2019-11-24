import SwiftUI

struct MyBar: View {
	let displayIngredients: [IngredientData]

	init() {
		self.displayIngredients = ingredients.values.filter({ $0.showSeparateFromParent }).sorted { $0.id < $1.id }
	}

	private func toggleFavorite(ingredient: IngredientData) {
	}

	var body: some View {
		return NavigationView {
			List {
				ForEach(displayIngredients) { ingredientData in
					HStack {
						Text(ingredientData.name.localizedCapitalized)
						Image(systemName: "checkmark")
							.foregroundColor(.blue)
						Spacer()
						NavigationLink(destination: Text("")) {
							Image(systemName: "info.circle")
								.foregroundColor(.gray)
						}
							.frame(maxWidth: 32, maxHeight: .greatestFiniteMagnitude)
							.offset(x: 8)
							.clipped()
						Button(action: {
							self.toggleFavorite(ingredient: ingredientData)
						}) {
							Image(systemName: "star")
								.foregroundColor(.yellow)
						}
							.frame(maxWidth: 32, maxHeight: .greatestFiniteMagnitude)
					}
				}
			}
				.navigationBarTitle("My Bar")
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
