import SwiftUI

struct Explore: View {
	var body: some View {
		let cocktails = CocktailData.keyValues.values.sorted { $0.id < $1.id }
		return GeometryReader { geometry in
			if geometry.size.width > 1112 {
				ExploreDoubleTripleColumn(cocktails: cocktails)
			} else if geometry.size.width > 960 { // Needed to fix SplitView behavior on narrow screens which hide master.
				ExploreSingleColumn(cocktails: cocktails)
			} else if geometry.size.width > 512 {
				ExploreDoubleTripleColumn(cocktails: cocktails)
					.navigationViewStyle(StackNavigationViewStyle())
			} else {
				ExploreSingleColumn(cocktails: cocktails)
			}
		}
	}
}

private struct ExploreDoubleTripleColumn: View {
	let cocktails: [CocktailData]

	var body: some View {
		NavigationView {
			BuildCocktailsDetailList(displayCocktails: cocktails, insertBlank: false)
				.navigationBarTitle("Explore")
			BuildCocktailPlaceholder()
		}
	}
}

private struct ExploreSingleColumn: View {
	let cocktails: [CocktailData]

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
