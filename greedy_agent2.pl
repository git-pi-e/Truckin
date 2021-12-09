:- dynamic
	agent_choice/2,
	agent_state2/1,
	moves_remaining/1,
	place/6,
	player/6,
	holding/3.

:- [agent_helpers2].
agent_name(greedy_agent2).

init_agent(greedy_agent2):-
	asserta(agent_state2(init)).

%Init
move(greedy_agent2,_,_):-
	agent_state2(init),
	set_agent_state2(decide_state),
	fail.

%Go home - can't reach fuel station
move(greedy_agent2, MoveType, MoveQuantity):-
	needs_fuel2,
	moves_remaining(MRem),
	player(greedy_agent2, WL, Cash, VL, Fuel, Where),
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

%Needs fuel - at fuel station before buying something
move(greedy_agent2, MoveType, MoveQuantity):-
	needs_fuel2,
	moves_remaining(MRem),
	player(greedy_agent2, WL, Cash, VL, Fuel, Where),
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

%Needs fuel - at station after buying something
move(greedy_agent2, MoveType, MoveQuantity):-
	needs_fuel2,
	% writeln('here'),
	moves_remaining(MRem),
	player(greedy_agent2, WL, Cash, VL, Fuel, Where),
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
	place(Index, _, 'Fuel', Quantity, Price, seller),
	item('Fuel', IW, IV),
	WLim is floor(WL/IW),
	VLim is floor(VL/IV),
	CLim is floor(Cash/Price),
	min_list([WLim,VLim, CLim],OurLimF),
	OurLim is floor(OurLimF),
	min_list([MRem*8, OurLim,100,floor(Quantity)],MoveQuantity).


%Needs fuel - not at station
move(greedy_agent2, MoveType, MoveQuantity):-
	needs_fuel2,
	% writeln('here'),
	moves_remaining(MRem),
	player(greedy_agent2, WL, Cash, VL, Fuel, Where),
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
	writeln('Move to fuel'),
	MoveType = m,
	step_to_go_to2(Index,MoveQuantity).

%From init
move(greedy_agent2,_,_):-
	agent_state2(decide_state),
	retractall( agent_choice(_,_) ),
	find_best_item2( BestSeller, BestBuyer ),
	asserta( agent_choice(BestSeller, BestBuyer) ),
	writeln(agent_choice(BestSeller, BestBuyer)),
	set_agent_state2(do_buy),
	fail.

%Buying
move(greedy_agent2, MoveType, MoveQuantity):-
	agent_state2(do_buy),
	player(greedy_agent2,_,_,_,_,Where),
	agent_choice(BestSeller,_),
	Where = BestSeller,
	writeln('Buying'),
	MoveType = t,
	max_buy2(MoveQuantity),
	set_agent_state2(do_sell).


%Moving when you want to buy
move(greedy_agent2, MoveType, MoveQuantity):-
	agent_state2(do_buy),
	player(greedy_agent2, _,_,_,_,Where),
	agent_choice(BestSeller, _),
	writeln('move to buy'),
	MoveType = m,
	step_to_go_to2(BestSeller, MoveQuantity).

%Selling
move(greedy_agent2, MoveType, MoveQuantity):-
	agent_state2(do_sell),
	player(greedy_agent2,_,_,_,_,Where),
	agent_choice(_, BestBuyer),
	Where = BestBuyer,
	writeln('selling'),
	MoveType = t,
	max_sell2(BestBuyer, MoveQuantity),
	set_agent_state2(decide_state).

%Moving when you want to sell
move(greedy_agent2, MoveType, MoveQuantity):-
	agent_state2(do_sell),
	player(greedy_agent2, _,_,_,_,Where),
	agent_choice(_,BestBuyer),
	writeln('move to sell'),
	MoveType = m,
	step_to_go_to2(BestBuyer, MoveQuantity).