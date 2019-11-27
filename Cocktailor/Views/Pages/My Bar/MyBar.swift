import SwiftUI

struct MyBar: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>

	let displayIngredients = IngredientData.keyValues.values.filter { $0.showSeparateFromParent }.sorted { $0.id < $1.id }

	var body: some View {
		var ingredientEntriesByID = [String: IngredientEntry]()
		for ingredientEntry in ingredientEntries {
			ingredientEntriesByID[ingredientEntry.id] = ingredientEntry
		}
		return NavigationView {
			List(displayIngredients) { data in
				IngredientListEntry(data: data, entry: .constant(ingredientEntriesByID[data.id]), observededIngredients: ObservableIngredients.inactive, hasCocktail: true)
			}
				.navigationBarTitle("My Bar")
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct MyBar_Previews: PreviewProvider {
	static var previews: some View {
		MyBar()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
