import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

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
		}
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		return CocktailDetail(data: bramble)
	}
}
