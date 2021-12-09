set_agent_state2(ToState):-
	retractall(agent_state2(_)),
	asserta( agent_state2(ToState) ).

needs_fuel2:-
	player(f2020A7PS0114G,_,_,_,Fuel,Where ),
	place(FinishIndex,_,_,_,_,finish),
	moves_remaining(MRemaining),
	FReqd is min(abs(Where-FinishIndex), abs(64-Where+FinishIndex))+20,
	MReqd is floor(FReqd/8)+1,
	( FReqd > Fuel; MReqd > MRemaining ).

step_to_go_to2( Dest, 0 ):-
	player(f2020A7PS0114G,_,_,_,_, Where ),
	Where = Dest.

step_to_go_to2(Dest, MoveQuantity):-
	player(f2020A7PS0114G,_,_,_,_, Where ),
	Diff is ((Dest-Where+64) mod 64),
	Diff < 32,
	MoveQuantity is min(8, Diff).

step_to_go_to2( Dest, MoveQuantity):-
	% Returns how many steps to move to go home
	player(f2020A7PS0114G,_,_,_,_, Where ),
	Diff is ((Dest-Where+64) mod 64),
	Diff >= 32,
	MoveQuantity is max(-8, Diff-64).

max_buy2(MoveQuantity):-
	agent_choice(BestSeller, BestBuyer),
	place(BestSeller,_,Item,SQ,Price,seller),
	SQ>0,
	place(BestBuyer,_,Item,BQ,_,buyer),
	BQ>0,
	player(f2020A7PS0114G, WL, Cash, VL, _, _),
	item( Item, IW, IV),
	WLim is floor(WL/IW),
	VLim is floor(VL/IV),
	CLim is floor(Cash/Price),
	min_list([WLim,VLim, CLim],OurLim),
	min_list([floor(SQ), floor(BQ), floor(OurLim)], MoveQuantity).

max_sell2( Buyer, MoveQuantity ):-
	% Sell everything you're holding
	place(Buyer, _,Item,_,_,_),
	holding(f2020A7PS0114G, Item, MoveQuantity1),
	MoveQuantity is floor(MoveQuantity1).

find_best_item2(BestSeller, BestBuyer):-
% Finds dealers with best ratio of how much profit we obtain on buying and selling Q of the item to how much fuel is required to get it. Here Q is the minimum of how much the buyer wants, how much the seller can sell and how much we can buy based on how much cash, weight and volume we have.
	player(f2020A7PS0114G, Weight, Cash, Volume, Fuel, Where),
	writeln(player(f2020A7PS0114G, Weight, Cash, Volume, Fuel, Where)),
	findall(
		pppdiff(Place1,Place2,Ratio), % Just a name for the structure
		(
				place(Place1,_,Item,Quantity1,Price1,seller),
				place(Place2,_,Item,Quantity2,Price2,buyer),
				Quantity1>0,
				Quantity2>0,
				item( Item, IW, IV),
				WLim is floor(Weight/IW),
				VLim is floor(Volume/IV),
				CLim is floor(Cash/Price1),
				min_list([WLim,VLim, CLim],OurLim),
				min_list([floor(Quantity1),floor(Quantity2),floor(OurLim)], Quantity),
				PriceDiff is Quantity*(Price2 - Price1),
				FReqd is min(abs(Place1-Where), abs(64+Where-Place1))+min(abs(Place2-Place1), abs(64-Place2+Place1)),
				Ratio is (2.5*PriceDiff+1.5*FReqd)/(2.5*PriceDiff-1.5*FReqd)
		),
		PPList
	),
	% writeln(PPList),
	find_max_pricediff( PPList, MaxPriceDiff),
	MaxPriceDiff = pppdiff(BestSeller, BestBuyer, _),
	place(BestSeller, _,_,_,Price, seller).
	% writeln(Price).

find_max_pricediff( PPList, MaxPriceDiff):-
	% Returns the member of PPList having max PriceDiff
	% pppdiff( Place1, Place2, PriceDiff)
	findall( PDiff, member(pppdiff(_,_,PDiff), PPList) , PDList ),
	max_list(PDList, MaxPDiff),
	member( pppdiff(Place1, Place2, MaxPDiff ), PPList ),
	MaxPriceDiff = pppdiff(Place1,Place2, MaxPDiff).


find_min_fueldiff( PPList, MinFuelDiff):-
	% Returns the member of PPList having min FuelDiff
	% pppdiff( Place1, Place2, FuelDiff)
	findall( FDiff, member(pppdiff(_,_,FDiff), PPList), FDList ),
	min_list(FDList, MinFDiff),
	member( pppdiff(Place1, Place2, MinFDiff ), PPList ),
	MinFuelDiff = pppdiff(Place1,Place2, MinFDiff).


:- dynamic
	agent_choice/2,
	agent_state2/1,
	moves_remaining/1,
	place/6,
	player/6,
	holding/3.

agent_name(f2020A7PS0114G).

init_agent(f2020A7PS0114G):-
	asserta(agent_state2(init)).


move(f2020A7PS0114G,_,_):-
	agent_state2(init),
	set_agent_state2(decide_state),
	fail.

move(f2020A7PS0114G, MoveType, MoveQuantity):-
	needs_fuel2,
	moves_remaining(MRem),
	player(f2020A7PS0114G, WL, Cash, VL, Fuel, Where),
	findall(
		pppdiff(Index,Where,FReqd), 
		(place(Index,_,'Fuel',_,Price,seller), 
		Price<Cash, 
		FReqd is min(abs(Where-Index), abs(64-Where+Index)),
		FReqd<Fuel,
		MReqd is FReqd/8,
		MReqd+7<MRem),
	FuelList),
	length(FuelList, Length),
	Length=0, %can't reach fuel station
	writeln('Needs to go home'),
	MoveType = m,
	place(FinishIndex,_,_,_,_,finish),
	step_to_go_to2( FinishIndex, MoveQuantity).

move(f2020A7PS0114G, MoveType, MoveQuantity):-
	needs_fuel2,
	moves_remaining(MRem),
	player(f2020A7PS0114G, WL, Cash, VL, Fuel, Where),
	findall(
		pppdiff(Index,Where,FReqd), 
		(place(Index,_,'Fuel',_,Price,seller), 
		Price<Cash, 
		FReqd is min(abs(Where-Index), abs(64-Where+Index)),
		FReqd<Fuel,
		MReqd is FReqd/8,
		MReqd+7<MRem),
	FuelList),
	% writeln(FuelList),
	length(FuelList, Length),
	Length>0,
	find_min_fueldiff( FuelList, MinFuelDiff),
	MinFuelDiff = pppdiff(Index, Where, _),
	Where = Index,
	writeln('Buy fuel'),
	MoveType = t,
	moves_remaining(MRem),
	MoveQuantity is min(MRem*8,100),
	agent_state2(do_buy),
	set_agent_state2(decide_state).

move(f2020A7PS0114G, MoveType, MoveQuantity):-
	needs_fuel2,
	% writeln('here'),
	moves_remaining(MRem),
	player(f2020A7PS0114G, WL, Cash, VL, Fuel, Where),
	findall(
		pppdiff(Index,Where,FReqd), 
		(place(Index,_,'Fuel',_,Price,seller), 
		Price<Cash, 
		FReqd is min(abs(Where-Index), abs(64-Where+Index)),
		FReqd<Fuel,
		MReqd is FReqd/8,
		MReqd+7<MRem),
	FuelList),
	writeln(FuelList),
	length(FuelList, Length),
	Length>0,
	find_min_fueldiff( FuelList, MinFuelDiff),
	MinFuelDiff = pppdiff(Index, Where, _),
	Where = Index,
	writeln('Buy fuel'),
	MoveType = t,
	moves_remaining(MRem),
	place(Index, _, 'Fuel', Quantity, Price, seller),
	item('Fuel', IW, IV),
	WLim is floor(WL/IW),
	VLim is floor(VL/IV),
	CLim is floor(Cash/Price),
	min_list([WLim,VLim, CLim],OurLimF),
	OurLim is floor(OurLimF),
	min_list([MRem*8, OurLim,100,floor(Quantity)],MoveQuantity).


move(f2020A7PS0114G, MoveType, MoveQuantity):-
	needs_fuel2,
	writeln('here'),
	moves_remaining(MRem),
	player(f2020A7PS0114G, WL, Cash, VL, Fuel, Where),
	findall(
		pppdiff(Index,Where,FReqd), 
		(place(Index,_,'Fuel',_,Price,seller), 
		Price<Cash, 
		FReqd is min(abs(Where-Index), abs(64-Where+Index)),
		FReqd<Fuel,
		MReqd is FReqd/8,
		MReqd+7<MRem),
	FuelList),
	writeln(FuelList),
	length(FuelList, Length),
	Length>0,
	find_min_fueldiff( FuelList, MinFuelDiff),
	MinFuelDiff = pppdiff(Index, Where, _),
	writeln('Move to fuel'),
	MoveType = m,
	step_to_go_to2(Index,MoveQuantity).

%From init
move(f2020A7PS0114G,_,_):-
	agent_state2(decide_state),
	retractall( agent_choice(_,_) ),
	find_best_item2( BestSeller, BestBuyer ),
	asserta( agent_choice(BestSeller, BestBuyer) ),
	writeln(agent_choice(BestSeller, BestBuyer)),
	set_agent_state2(do_buy),
	fail.

%Buying
move(f2020A7PS0114G, MoveType, MoveQuantity):-
	agent_state2(do_buy),
	player(f2020A7PS0114G,_,_,_,_,Where),
	agent_choice(BestSeller,_),
	Where = BestSeller,
	writeln('Buying'),
	MoveType = t,
	max_buy2(MoveQuantity),
	set_agent_state2(do_sell).


%Moving when you want to buy
move(f2020A7PS0114G, MoveType, MoveQuantity):-
	agent_state2(do_buy),
	player(f2020A7PS0114G, _,_,_,_,Where),
	agent_choice(BestSeller, _),
	writeln('move to buy'),
	MoveType = m,
	step_to_go_to2(BestSeller, MoveQuantity).

%Selling
move(f2020A7PS0114G, MoveType, MoveQuantity):-
	agent_state2(do_sell),
	player(f2020A7PS0114G,_,_,_,_,Where),
	agent_choice(_, BestBuyer),
	Where = BestBuyer,
	writeln('selling'),
	MoveType = t,
	max_sell2(BestBuyer, MoveQuantity),
	set_agent_state2(decide_state).

%Moving when you want to sell
move(f2020A7PS0114G, MoveType, MoveQuantity):-
	agent_state2(do_sell),
	player(f2020A7PS0114G, _,_,_,_,Where),
	agent_choice(_,BestBuyer),
	writeln('move to sell'),
	MoveType = m,
	step_to_go_to2(BestBuyer, MoveQuantity).
