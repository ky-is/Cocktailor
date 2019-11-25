import SwiftUI

struct IngredientDetail: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?

	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
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
			}
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

struct IngredientDetail_Previews: PreviewProvider {
	static var previews: some View {
		let data = IngredientData(id: "test", name: "test ingredient", nicknames: ["testy", "tasty"], category: .wine, alcohol: 0.42, color: .blue, region: "France")
		return IngredientDetail(data: data, entry: .constant(nil))
	}
}
