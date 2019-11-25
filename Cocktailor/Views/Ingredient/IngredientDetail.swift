import SwiftUI

struct IngredientDetail: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?

	var body: some View {
		NavigationView {
			VStack {
				HStack {
					ForEach(data.nicknames, id: \.self) {
						Text($0)
					}
				}
				if data.alcohol > 0 {
					Text("Alcohol: \(NumberFormatter.localizedString(from: NSNumber(value: data.alcohol), number: .percent))")
				}
				if data.region != nil {
					Text("Region: \(data.region!)")
				}
				ScrollView(.horizontal) {
					HStack {
						ForEach(data.getCocktails()) { cocktail in
							ZStack {
								Capsule(style: .continuous)
									.fill(Color.secondarySystemBackground)
									.shadow(color: Color.black.opacity(0.1), radius: 3, y: 2)
								VStack {
									Text(cocktail.name)
										.fixedSize()
									HStack {
										ForEach(cocktail.ingredients) { ingredientQuantity in
											NavigationLink(destination: CocktailDetail(data: cocktail)) {
												IngredientIcon(data: ingredientQuantity.ingredient)
											}
										}
									}
										.padding(.horizontal, 8)
								}
							}
								.frame(minWidth: 128, maxHeight: 96)
						}
					}
						.padding()
				}
			}
				.padding()
				.navigationBarTitle(data.name.localizedCapitalized)
				.navigationBarItems(trailing:
					HStack {
						Group {
							ButtonFavorite(data: data, entry: $entry)
							ButtonOwned<Text?>(data: data, entry: $entry, content: nil)
						}
							.frame(width: 24)
					}
				)
		}
			.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct IngredientEntryDetail: View {
	let data: IngredientData

	@FetchRequest private var ingredientEntries: FetchedResults<IngredientEntry>

	init(data: IngredientData) {
		self.data = data
		let sortDescriptor = NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)
		let predicate = NSPredicate(format: "id == %@", data.id)
		self._ingredientEntries = FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
	}

	var body: some View {
		IngredientDetail(data: data, entry: .constant(ingredientEntries.first))
	}
}


struct IngredientDetail_Previews: PreviewProvider {
	static var previews: some View {
		return IngredientDetail(data: lime, entry: .constant(nil))
	}
}
