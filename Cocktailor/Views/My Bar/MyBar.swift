import SwiftUI

struct MyBar: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>

	let displayIngredients: [IngredientData]

	init() {
		self.displayIngredients = ingredients.values.filter { $0.showSeparateFromParent }.sorted { $0.id < $1.id }
	}

	var body: some View {
		var ingredientEntriesByID = [String: IngredientEntry]()
		for ingredientEntry in ingredientEntries {
			ingredientEntriesByID[ingredientEntry.id] = ingredientEntry
		}
		return NavigationView {
			List {
				ForEach(displayIngredients) { ingredientData in
					IngredientListEntry(data: ingredientData, entry: .constant(ingredientEntriesByID[ingredientData.id]))
				}
			}
				.navigationBarTitle("My Bar")
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

private struct IngredientListEntry: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?

	@State private var showInfo = false

	@Environment(\.managedObjectContext) private var managedObjectContext

	var body: some View {
		HStack {
			ButtonOwned(data: data, entry: $entry) {
				HStack {
					Text(self.data.name.localizedCapitalized)
						.foregroundColor(.primary)
					Spacer()
				}
			}
				.buttonStyle(BorderlessButtonStyle())
			ButtonFavorite(data: data, entry: $entry)
				.buttonStyle(BorderlessButtonStyle())
				.frame(width: 28)
			Button(action: {
				self.showInfo.toggle()
			}) {
				Image(systemName: "info.circle")
					.foregroundColor(.secondary)
					.frame(width: 28)
			}
				.buttonStyle(BorderlessButtonStyle())
		}
			.sheet(isPresented: $showInfo) {
				IngredientDetail(data: self.data, entry: self.$entry)
			}
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
