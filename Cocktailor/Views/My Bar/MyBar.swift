import SwiftUI

struct MyBar: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) var ingredientEntries: FetchedResults<IngredientEntry>

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

	@Environment(\.managedObjectContext) var managedObjectContext

	private func toggleOwned() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.owned.toggle()
				try? self.managedObjectContext.save()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.owned = true
				try? self.managedObjectContext.save()
			}
		}
	}

	private func toggleFavorite() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.favorite.toggle()
				DataModel.saveContext()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.favorite = true
				DataModel.saveContext()
			}
		}
	}

	var body: some View {
		let owned = entry?.owned ?? false
		return HStack {
			Image(systemName: owned ? "checkmark" : "circle")
				.foregroundColor(owned ? .blue : .secondary)
				.frame(width: 24)
			Button(action: toggleOwned) {
				Text(data.name.localizedCapitalized)
					.foregroundColor(.primary)
				Spacer()
			}
				.buttonStyle(BorderlessButtonStyle())
			Button(action: toggleFavorite) {
				Image(systemName: entry?.favorite ?? false ? "star.fill" : "star")
					.foregroundColor(.yellow)
					.frame(width: 28)
			}
				.buttonStyle(BorderlessButtonStyle())
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
				Text("!")
			}
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
