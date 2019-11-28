import SwiftUI

struct Substitute {
	let ingredient: IngredientData
	let score: Double
}

final class IngredientData: Hashable, Identifiable {
	static let keyValues: [String: IngredientData] = {
		[
			(lemon, lime, 0.5),
//			(agave, syrupMaple, 0.5),
			(brandy, brandyApple, 0.5),
			(brandy, brandyCognac, 0.5),
			(cream, creamHeavy, 0.5),
			(gin, vodka, 0.5),
			(rumLight, rumGold, 0.5),
			(rumGold, rumDark, 0.5),
//			(rumLight, cachaca, 0.2),
			(liqueurBlackberry, liqueurBlackcurrant, 0.5),
			(sugar, sugarBrown, 0.8),
//			(champagne, prosecco, 0.8),
			(whiskey, whiskeyBourbon, 0.8),
			(whiskey, whiskeyIrish, 0.8),
			(whiskey, whiskeyRye, 0.8),
			(whiskey, whiskeyScotch, 0.8),
			(whiskeyIrish, whiskeyScotch, 0.8),
		].forEach { (first, second, score) in
			first.substitutions.append(Substitute(ingredient: second, score: score))
			second.substitutions.append(Substitute(ingredient: first, score: score))
		}
		let items = [
//			absinthe,
//			agave,
//			amaretto,
			bitters,
			aperol,
//			apple,
			brandy,
			brandyApple,
			brandyApricot,
			brandyCognac,
			cachaca,
			campari,
//			champagne,
//			cherryMaraschino,
			coconutCream,
			coffee,
			cream,
			creamHeavy,
			egg,
			gin,
			gingerBeer,
//			IngredientData(id: "eggyolk", name: "egg yolk", parent: egg, showSeparateFromParent: false),
//			IngredientData(id: "eggwhite", name: "egg white", parent: egg, showSeparateFromParent: false),
			irishCream,
			juiceCranberry,
			juiceGrapefruit,
			juiceOrange,
			juicePineapple,
			lemon,
			lime,
			liqueurRasberry,
			liqueurBlackberry,
			liqueurBlackcurrant,
			liqueurChocolate,
			liqueurCoffee,
			liqueurOrange,
			mezcal,
			prosecco,
			rumLight,
			rumGold,
			rumDark,
			sodaClub,
			sodaCola,
			sugar,
			sugarBrown,
			syrupMaple,
			syrupSimple,
			tequila,
			vermouthDry,
			vermouthSweet,
			whiskey,
			whiskeyBourbon,
			whiskeyIrish,
			whiskeyRye,
			whiskeyScotch,
			vodka,
		]
		var results = [String: IngredientData]()
		for item in items {
			results[item.id] = item
		}
		return results
	}()

	let id: String
	let name: String
	let nicknames: [String]
	let icon: IngredientIcon
	let category: IngredientCategory
	let alcohol: Double
	let color: Color
	let region: String?
	let wikipedia: String?
	let parent: IngredientData?
	let showSeparateFromParent: Bool
	var children: [IngredientData] = []
	var tags: [String]
	var substitutions: [Substitute] = []

	init(id: String, name: String, nicknames: [String]? = nil, icon: IngredientIcon, category: IngredientCategory, alcohol: Double = 0, color: Color, region: String? = nil, wikipedia: String? = nil, parent: IngredientData? = nil, showSeparateFromParent: Bool = true, tags: [String]? = nil) {
		self.id = id
		self.name = name
		self.nicknames = nicknames ?? []
		self.icon = icon
		self.category = category
		self.alcohol = alcohol
		self.color = color
		self.region = region
		self.wikipedia = wikipedia
		self.parent = parent
		self.showSeparateFromParent = showSeparateFromParent
		self.tags = tags ?? []
		if parent != nil {
			parent?.children.append(self)
		}
	}

	static func == (lhs: IngredientData, rhs: IngredientData) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	var substitutionIDs: [String] {
		return substitutions.map { $0.ingredient.id }
	}

	func getCocktails() -> [CocktailData] {
		return CocktailData.keyValues.values.filter { cocktail in
			return cocktail.ingredients.contains { $0.ingredient.id == id }
		}
	}
}

enum IngredientIcon: String {
	case drop, fizz, grains, liquor, liqueur, aperitif
}

enum IngredientCategory: String {
	case aperitif, dairy, fruit, garnish, juice, liqueur, liquor, mixer, sweetener, wine
}

//let absinthe = IngredientData(id: "absinthe", name: "absinthe", alcohol: 0.60, wikipedia: "Absinthe")
//let agave = IngredientData(id: "agave", name: "agave nectar", icon: .liquor, category: .sweetener)
//let amaretto = IngredientData(id: "amaretto", name: "amaretto", icon: .liquor, category: .aperitif, alcohol: 0.24, region: "Italy", wikipedia: "Amaretto"])
let aperol = IngredientData(id: "aperol", name: "aperol", icon: .aperitif, category: .aperitif, alcohol: 0.11, color: .red, region: "Italy", wikipedia: "Aperol")
let bitters = IngredientData(id: "bitters", name: "bitters", nicknames: ["Angostura bitters"], icon: .aperitif, category: .aperitif, alcohol: 0.447, color: .brown, region: "Trinidad and Tobago", wikipedia: "Angostura_bitters")
//let apple = IngredientData(id: "apple", icon: .drop, category: .fruit, name: "apple", color: .red)
let brandy = IngredientData(id: "brandy", name: "brandy", nicknames: ["eau de vie"], icon: .liquor, category: .liquor, alcohol: 0.40, color: .white, region: "worldwide", wikipedia: "Brandy")
let brandyApple = IngredientData(id: "brandyApple", name: "apple brandy", icon: .liqueur, category: .liquor, alcohol: 0.40, color: .brown, wikipedia: "Apple_brandy")
let brandyApricot = IngredientData(id: "brandyApricot", name: "apricot brandy", icon: .liqueur, category: .liquor, alcohol: 0.40, color: .red, wikipedia: "Apricot_brandy")
let brandyCognac = IngredientData(id: "brandyCognac", name: "Cognac", icon: .liqueur, category: .liquor, alcohol: 0.40, color: .brown, region: "France", wikipedia: "Cognac")
let cachaca = IngredientData(id: "cachaca", name: "cachaça", icon: .liqueur, category: .liquor, alcohol: 0.40, color: .yellow, region: "Brazil", wikipedia: "Cachaca")
let campari = IngredientData(id: "campari", name: "campari", icon: .aperitif, category: .aperitif, alcohol: 0.25, color: .red, region: "Italy", wikipedia: "Campari")
//let champagne = IngredientData(id: "champagne", name: "champagne", alcohol: 0.12, color: .yellow, region: "France (Champagne)", wikipedia: "Champagne")
//let cherryMaraschino = IngredientData(id: "cherryCocktail", name: "Maraschino cherry", nicknames: ["cocktail cherry"], color: .red, wikipedia: "Maraschino_cherry")
let coconutCream = IngredientData(id: "coconutCream", name: "cream of coconut", icon: .drop, category: .juice, color: .white, wikipedia: "Coconut_milk#Cream_of_coconut")
let coffee = IngredientData(id: "coffee", name: "coffee", icon: .drop, category: .mixer, color: .black, wikipedia: "Coffee") //TODO cat
let cream = IngredientData(id: "cream", name: "cream", icon: .drop, category: .dairy, color: .white, wikipedia: "Cream")
let creamHeavy = IngredientData(id: "creamHeavy", name: "heavy cream", nicknames: ["whipping cream"], icon: .drop, category: .dairy, color: .white, wikipedia: "Cream#Types")
let egg = IngredientData(id: "egg", name: "egg", icon: .drop, category: .dairy, color: .white)
let gin = IngredientData(id: "gin", name: "gin", icon: .liquor, category: .liquor, alcohol: 0.40, color: .green, region: "Worldwide", wikipedia: "Gin")
let gingerBeer = IngredientData(id: "gingerBeer", name: "ginger beer", icon: .fizz, category: .mixer, color: .green)
let herbMint = IngredientData(id: "herbMint", name: "mint", icon: .liquor, category: .garnish, color: .green, wikipedia: "Mint")
let irishCream = IngredientData(id: "irishCream", name: "Irish cream", icon: .liqueur, category: .liqueur, alcohol: 0.175, color: .black, region: "Ireland", wikipedia: "Irish_cream")
let juiceCranberry = IngredientData(id: "juiceCranberry", name: "cranberry juice", icon: .drop, category: .juice, color: .red)
let juiceGrapefruit = IngredientData(id: "juiceGrapefruit", name: "grapefruit juice", icon: .drop, category: .juice, color: .pink)
let juiceOrange = IngredientData(id: "juiceOrange", name: "orange juice", icon: .drop, category: .juice, color: .orange)
let juicePineapple = IngredientData(id: "juicePineapple", name: "pineapple juice", icon: .drop, category: .juice, color: .yellow)
let lemon = IngredientData(id: "lemon", name: "lemon", icon: .drop, category: .fruit, color: .yellow)
let lime = IngredientData(id: "lime", name: "lime", icon: .drop, category: .fruit, color: .green)
let liqueurRasberry = IngredientData(id: "liquerRasberry", name: "rasberry liqueur", nicknames: ["chambour"], icon: .liqueur, category: .liqueur, alcohol: 0.20, color: .red, region: "France", wikipedia: "Chambord_(liqueur)")
let liqueurBlackberry = IngredientData(id: "liquerBlackberry", name: "blackberry liqueur", nicknames: ["crème de mûre"], icon: .liqueur, category: .liqueur, alcohol: 0.20, color: .purple, region: "France", wikipedia: "Crème_liqueur")
let liqueurBlackcurrant = IngredientData(id: "liquerBlackcurrant", name: "blackcurrant liqueur", nicknames: ["crème de cassis"], icon: .liqueur, category: .liqueur, alcohol: 0.20, color: .black, region: "France (Burgundy)", wikipedia: "Crème_de_cassis")
//let liqueurCherry = IngredientData(id: "liqueurCherry", name: "cherry liqueur", icon: .liquor, category: .liqueur, alcohol: 0.24)
let liqueurChocolate = IngredientData(id: "liqueurChocolate", name: "chocolate liqueur", nicknames: ["crème de cacao"], icon: .liqueur, category: .liqueur, alcohol: 0.25, color: .brown)
let liqueurCoffee = IngredientData(id: "liqueurCoffee", name: "coffee liqueur", nicknames: ["Kahlúa"], icon: .liqueur, category: .liqueur, alcohol: 0.20, color: .black, region: "Mexico")
let liqueurOrange = IngredientData(id: "liqueurOrange", name: "orange liqueur", nicknames: ["Curaçao", "Triple Sec", "Cointreau", "Grand Marnier"], icon: .liqueur, category: .liqueur, alcohol: 0.40, color: .orange, region: "Netherlands/France")
let mezcal = IngredientData(id: "mezcal", name: "mezcal", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "Mexico", wikipedia: "Mezcal")
let prosecco = IngredientData(id: "prosecco", name: "prosecco", icon: .liquor, category: .wine, alcohol: 0.11, color: .clear, region: "Italy", wikipedia: "Prosecco")
let rumLight = IngredientData(id: "rumLight", name: "light rum", nicknames: ["silver rum", "white rum"], icon: .liquor, category: .liquor, alcohol: 0.40, color: .clear, wikipedia: "Rum")
let rumGold = IngredientData(id: "rumGold", name: "gold rum", nicknames: ["silver rum", "light rum"], icon: .liquor, category: .liquor, alcohol: 0.40, color: .orange, wikipedia: "Rum")
let rumDark = IngredientData(id: "rumDark", name: "dark rum", nicknames: ["silver rum", "light rum"], icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, wikipedia: "Rum")
let sodaClub = IngredientData(id: "sodaClub", name: "club soda", icon: .fizz, category: .mixer, color: .clear, wikipedia: "Club_soda")
let sodaCola = IngredientData(id: "sodaCola", name: "cola soda", icon: .fizz, category: .mixer, color: .brown, wikipedia: "Cola")
let sugar = IngredientData(id: "sugar", name: "sugar", icon: .grains, category: .sweetener, color: .white, wikipedia: "Sugar")
let sugarBrown = IngredientData(id: "sugarBrown", name: "brown sugar", icon: .grains, category: .sweetener, color: .brown, wikipedia: "Brown_sugar")
let syrupMaple = IngredientData(id: "syrupMaple", name: "maple syrup", icon: .aperitif, category: .sweetener, color: .brown)
let syrupSimple = IngredientData(id: "syrupSimple", name: "simple syrup", icon: .aperitif, category: .sweetener, color: .clear)
let syrupAlmond = IngredientData(id: "syrupAlmond", name: "almond syrup", nicknames: ["Orgeat syrup"], icon: .aperitif, category: .sweetener, color: .brown, wikipedia: "Orgeat_syrup")
let tequila = IngredientData(id: "tequila", name: "tequila", icon: .liquor, category: .liquor, alcohol: 0.40, color: .clear, region: "Mexico", wikipedia: "Tequila")
let vermouthDry = IngredientData(id: "vermouthDry", name: "dry vermouth", icon: .liquor, category: .liquor, alcohol: 0.18, color: .green, region: "Italy", wikipedia: "Vermouth")
let vermouthSweet = IngredientData(id: "vermouthSweet", name: "sweet vermouth", icon: .liquor, category: .wine, alcohol: 0.165, color: .purple, region: "Italy", wikipedia: "Vermouth")
let whiskey = IngredientData(id: "whiskey", name: "whiskey", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "Worldwide", wikipedia: "Whiskey")
let whiskeyBourbon = IngredientData(id: "whiskeyBourbon", name: "Bourbon", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "United States (Kentucky)", wikipedia: "Bourbon")
let whiskeyIrish = IngredientData(id: "whiskeyIrish", name: "Irish whiskey", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "Ireland", wikipedia: "Irish_whiskey")
let whiskeyRye = IngredientData(id: "whiskeyRye", name: "rye whiskey", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "United States", wikipedia: "Rye_whiskey")
let whiskeyScotch = IngredientData(id: "whiskeyScotch", name: "Scotch whiskey", icon: .liquor, category: .liquor, alcohol: 0.40, color: .brown, region: "Scotland", wikipedia: "Scotch_whisky")
let vodka = IngredientData(id: "vodka", name: "vodka", icon: .liquor, category: .liquor, alcohol: 0.40, color: .clear, region: "Russia", wikipedia: "Vodka")
