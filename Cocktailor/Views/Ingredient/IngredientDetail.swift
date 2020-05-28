import SwiftUI

struct IngredientDetail: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	let isModal: Bool

	@Environment(\.presentationMode) private var presentationMode

	var body: some View {
		NavigationView {
			VStack {
				HStack {
					ForEach(data.nicknames, id: \.self) {
						Text($0)
					}
				}
				IngredientImage(data: data, size: 64)
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
												IngredientImage(data: ingredientQuantity.ingredient, size: 32)
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
				.navigationBarItems(
					leading:
						Group {
							if isModal {
								Button(action: {
									self.presentationMode.wrappedValue.dismiss()
								}) {
									Text("Dismiss")
								}
							}
						},
					trailing:
						HStack {
							Group {
								IngredientButtonFavorite(data: data, entry: $entry)
								IngredientButtonOwned(data: data, entry: $entry, hasCocktail: true, withContent: true)
							}
								.frame(width: 24)
								.padding(.leading)
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
		self._ingredientEntries = FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [sortDescriptor], predicate: \IngredientEntry.id == data.id)
	}

	var body: some View {
		IngredientDetail(data: data, entry: .constant(ingredientEntries.first), isModal: false)
	}
}

struct IngredientDetail_Previews: PreviewProvider {
	static var previews: some View {
		let data = IngredientData.keyValues["mezcal"]!
		return IngredientDetail(data: data, entry: .constant(nil), isModal: false)
	}
}
