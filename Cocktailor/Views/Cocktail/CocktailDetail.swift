import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false)], predicate: NSPredicate(format: "owned == TRUE")) private var ownedIngredientEntries: FetchedResults<IngredientEntry>
	@State private var selectedIngredient: IngredientData?

	var body: some View {
		let ownedIngredientIDs = ownedIngredientEntries.map { $0.id }
		return GeometryReader { geometry in
			ScrollView {
				HStack {
					ForEach(self.data.nicknames, id: \.self) {
						Text($0)
					}
				}
				CocktailImage(data: self.data, size: geometry.size.width / 2)
				Text("Alcohol: \(NumberFormatter.localizedString(from: NSNumber(value: self.data.alcohol), number: .percent))")
				if self.data.region != nil {
					Text("Region: \(self.data.region!)")
				}
				VStack {
					ForEach(self.data.ingredients) { ingredientQuantity in
						CocktailDetailRow(selectedIngredient: self.$selectedIngredient, data: ingredientQuantity, ownedIngredientIDs: ownedIngredientIDs)
					}
				}
					.padding()
					.frame(maxWidth: 360)
			}
		}
			.navigationBarTitle(data.name)
			.sheet(item: $selectedIngredient) { selectedIngredient in
				IngredientEntryDetail(data: selectedIngredient)
					.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
					.accentColor(.primary)
			}
	}
}

private struct CocktailDetailRow: View {
	@Binding var selectedIngredient: IngredientData?
	let data: IngredientQuantity
	let ownedIngredientIDs: [String]

	var body: some View {
		let isOwned = data.ingredient.usableIn(available: ownedIngredientIDs) != nil
		let substitute = isOwned ? nil : data.ingredient.findSubstitute(available: ownedIngredientIDs)
		return Button(action: {
			self.selectedIngredient = substitute ?? self.data.ingredient
		}) {
			return HStack(spacing: 0) {
				IngredientListItem(data: data.ingredient, available: isOwned, substitute: substitute)
				Spacer()
				Text(data.quantity.value.description)
					.foregroundColor(.primary)
				+
				Text(" \(data.quantity.unit.rawValue) ")
					.foregroundColor(.secondary)
			}
		}
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		let data = CocktailData.keyValues["bramble"]!
		return NavigationView {
			CocktailDetail(data: data)
				.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
		}
	}
}
