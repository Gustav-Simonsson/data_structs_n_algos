-module(treap).
-compile(export_all).

-define(MAX_SIZE, 1024).

%% treap:new().
new() ->
    {A,B,C} = now(),
    random:seed(A,B,C),
    %% {Value, Priority, Left, Right}
    nil.

insert(Treap, V) ->
    RootP = case Treap of
                nil -> nil;
                {_, PP, _, _} -> PP
            end,
    {_, NewTreap} = insert(Treap, RootP, V),
    NewTreap.

%% http://upload.wikimedia.org/wikipedia/commons/1/15/Tree_Rotations.gif
%% short naming: (P)arent (P)riority, (R)ight (V)alue etc.
insert(nil, PP, NewV) ->
    {_, NP, _, _} = NewNode = new_node(NewV),
    {rotation_required(NP, PP), %% inform upper level whether to rotate
     NewNode};

insert({V, P, Left, Right}, PP, NewV) when NewV =< V ->
    case insert(Left, P, NewV) of
        {no_rotate, NewLeft} ->
            {rotation_required(P, PP),
             {V, P, NewLeft, Right}};
        {rotate, {LV, LP, LL, LR}} ->
            {rotation_required(P, PP),
             {LV, LP, LL, {V, P, LR, Right}}} %% right rotation
    end;
insert({V, P, Left, Right}, PP, NewV) when NewV > V ->
    case insert(Right, P, NewV) of
        {no_rotate, NewRight} ->
            {rotation_required(P, PP), {V, P, Left, NewRight}};
        {rotate, {RV, RP, RL, RR}} ->
            {rotation_required(P, PP),
             {RV, RP, {V, P, Left, RL}, RR}} %% left rotation
    end.

rotation_required(NP, nil)               -> no_rotate; %% root has no parent
rotation_required(NP, PP)  when NP >= PP -> no_rotate;
rotation_required(_,_)                   -> rotate.

new_node(Value) ->
    {Value, new_priority(), nil, nil}.

new_priority() ->
    random:uniform(?MAX_SIZE).

test1() ->
    T = treap:new(),
    T2 = treap:insert(T, 7),
    T3 = treap:insert(T2, 5),
    T4 = treap:insert(T3, 4),
    T5 = treap:insert(T4, 3),
    T6 = treap:insert(T5, 2),
    T6.
