import SwiftUI

struct Explore: View {
	var body: some View {
		NavigationView {
			BuildCocktailsDetailList(displayCocktails: CocktailData.keyValues.values.sorted { $0.id < $1.id }, insertBlank: false)
				.navigationBarTitle("Explore")
			BuildCocktailPlaceholder()
		}
	}
}

struct Explore_Previews: PreviewProvider {
	static var previews: some View {
		Explore()
	}
}
