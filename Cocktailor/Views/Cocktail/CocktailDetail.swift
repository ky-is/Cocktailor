import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

	@State private var selectedIngredient: IngredientData?

	var body: some View {
		GeometryReader { geometry in
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
						Button(action: {
							self.selectedIngredient = ingredientQuantity.ingredient
						}) {
							HStack(spacing: 0) {
								IngredientImage(data: ingredientQuantity.ingredient, size: 36)
								Text(ingredientQuantity.ingredient.name.localizedCapitalized)
									.padding(.trailing)
								Spacer()
								Text(ingredientQuantity.quantity.value.description)
									.foregroundColor(.primary)
								+
								Text(" \(ingredientQuantity.quantity.unit.rawValue) ")
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
					.accentColor(.primary)
			}
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		let data = CocktailData.keyValues["bramble"]!
		return NavigationView {
			CocktailDetail(data: data)
		}
	}
}
