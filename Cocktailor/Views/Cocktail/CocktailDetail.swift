import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

	@State private var selectedIngredient: IngredientData?

	var body: some View {
		GeometryReader { geometry in
			VStack {
				HStack {
					ForEach(self.data.nicknames, id: \.self) {
						Text($0)
					}
				}
				CocktailImage(data: self.data, height: geometry.size.width / 2)
				if self.data.alcohol > 0 {
					Text("Alcohol: \(NumberFormatter.localizedString(from: NSNumber(value: self.data.alcohol), number: .percent))")
				}
				if self.data.region != nil {
					Text("Region: \(self.data.region!)")
				}
				VStack {
					ForEach(self.data.ingredients) { ingredientAndQuantity in
						Button(action: {
							self.selectedIngredient = ingredientAndQuantity.ingredient
						}) {
							HStack {
								IngredientImage(data: ingredientAndQuantity.ingredient, size: 36)
								Text(ingredientAndQuantity.ingredient.name.localizedCapitalized)
									.padding(.trailing)
								Spacer()
								Text(ingredientAndQuantity.quantity.value.description)
									+
									Text(" \(ingredientAndQuantity.quantity.type.rawValue)")
										.foregroundColor(.secondary)
							}
						}
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
			}
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CocktailDetail(data: bramble)
		}
	}
}
