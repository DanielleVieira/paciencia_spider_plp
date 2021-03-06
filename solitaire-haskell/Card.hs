module Card where

	{- CARD-}

	data Card = Card {
	value :: Int,
	turned :: Bool
	} deriving (Eq, Show)


	invalidCard = Card {value = (-1), turned = False}

	newCard :: Int -> Bool -> Card
	newCard v t = Card {value = v, turned = t}

	isTurned :: Card -> Bool
	isTurned (Card v t) = t

	setCardTurned :: Card -> Card
	setCardTurned (Card v _) = Card {value = v, turned = True}

	setCardNotTurned :: Card -> Card
	setCardNotTurned (Card v _) = Card {value = v, turned = False}

	getValue :: Card -> Int
	getValue (Card v t) = v

	cardEquals :: Card -> Card -> Bool
	cardEquals (Card v1 t1) (Card v2 t2) = if v1 == v2 then True else False

	isValidCard :: Card -> Bool
	isValidCard (Card v t) = if v > 0 && v <= 13 then True else False

	toString :: Card -> String
	toString (Card v t)	| (v == 1)	&& t = "| Ace |" 
						| (v == 2) 	&& t = "|  2  |" 
						| (v == 3) 	&& t = "|  3  |" 
						| (v == 4) 	&& t = "|  4  |" 
						| (v == 5) 	&& t = "|  5  |"
	               		| (v == 6) 	&& t = "|  6  |" 
	               		| (v == 7) 	&& t = "|  7  |" 
	               		| (v == 8) 	&& t = "|  8  |" 
	               		| (v == 9) 	&& t = "|  9  |" 
	               		| (v == 10)	&& t = "| 10  |"
	               		| (v == 11)	&& t = "| Jack|" 
	               		| (v == 12)	&& t = "|Queen|" 
	               		| (v == 13)	&& t = "| King|"
	               		| t == False 	 = "|-----|"
	               		| otherwise 	 = "|     |"