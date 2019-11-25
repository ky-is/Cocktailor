import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

	var body: some View {
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
			VStack {
				ForEach(data.ingredients) { ingredientAndQuantity in
					HStack {
						IngredientIcon(data: ingredientAndQuantity.ingredient)
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
				.padding()
				.frame(maxWidth: 360)
		}
			.navigationBarTitle(data.name)
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CocktailDetail(data: bramble)
		}
	}
}
