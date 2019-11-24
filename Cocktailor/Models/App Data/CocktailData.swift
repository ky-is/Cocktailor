enum CocktailTag: String {
	case aperitif
}

enum BarEquipment {
	case barspoon
}

enum BarGlasses {
	case collins
}


final class CocktailData: Identifiable {
	let id: String
	let name: String
	let nicknames: [String]
	let alcohol: Double
	let ingredients: [String]
	let glass: BarGlasses
	let equipment: [BarEquipment]
	let region: String?
	let wikipedia: String?
	var related: [CocktailData]
	var tags: [CocktailTag]

	init(id: String, name: String, nicknames: [String]? = nil, alcohol: Double, ingredients: [String], glass: BarGlasses, equipment: [BarEquipment], region: String? = nil, wikipedia: String? = nil, related: [CocktailData] = [], tags: [CocktailTag]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.alcohol = alcohol
		self.ingredients = ingredients
		self.glass = glass
		self.equipment = equipment
		self.region = region
		self.wikipedia = wikipedia
		self.related = related
		self.tags = tags ?? []
	}
}

let cocktails: [String: CocktailData] = {
	let items = [
		CocktailData(id: "moscowMule", name: "Moscow mule", alcohol: 0.09, ingredients: ["vodka", "lime", "gingerBeer"], glass: .collins, equipment: [.barspoon], wikipedia: "Moscow_mule", related: [])
	]
	var results = [String: CocktailData]()
	for item in items {
		results[item.id] = item
	}
	return results
}()
