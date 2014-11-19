%% Run with:
%% erlc treap.erl && erl
%% treap:test1().

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

insert({V, P, L, R}, PP, NewV) when NewV =< V ->
    case insert(L, P, NewV) of
        {no_rotate, NewL} ->
            {rotation_required(P, PP),
             {V, P, NewL, R}};
        {rotate, {LV, LP, LL, LR}} ->
            {rotation_required(P, PP),
             {LV, LP, LL, {V, P, LR, R}}} %% right rotation
    end;
insert({V, P, L, R}, PP, NewV) when NewV > V ->
    case insert(R, P, NewV) of
        {no_rotate, NewR} ->
            {rotation_required(P, PP), {V, P, L, NewR}};
        {rotate, {RV, RP, RL, RR}} ->
            {rotation_required(P, PP),
             {RV, RP, {V, P, L, RL}, RR}} %% left rotation
    end.

delete({DeleteV, _, nil, nil}, DeleteV) -> nil;
delete({DeleteV, _, L, nil}, DeleteV)   -> L;
delete({DeleteV, _, nil, R}, DeleteV)   -> R;
delete(nil, _)                          -> nil;
delete(Node = {_, _, nil, nil}, _)      -> Node;
delete({V, P, L, nil}, DeleteV) -> {V, P, delete(L, DeleteV), nil};
delete({V, P, nil, R}, DeleteV) -> {V, P, nil, delete(R, DeleteV)};

%% Swap the child to delete with it's immediate successor in sorted order
delete({V, P, DeleteNode = {DeleteV, _, _, _}, R}, DeleteV) ->
    {DeleteOrSwap, NewL} = delete_or_swap(DeleteNode),
    case DeleteOrSwap of
        delete -> {V, P, NewL, R};
        swap   -> delete({V, P, NewL, R}, DeleteV)
    end;
%% TODO: can we abstract common pattern here for left/right child?
delete({V, P, L, DeleteNode = {DeleteV, _, _, _}}, DeleteV) ->
    {DeleteOrSwap, NewR} = delete_or_swap(DeleteNode),
    case DeleteOrSwap of
        delete -> {V, P, L, NewR};
        swap   -> delete({V, P, L, NewR}, DeleteV)
    end;

delete({V, P, L, R}, DeleteV) ->
    case DeleteV =< V of
        true ->
            {V, P, delete(L, DeleteV), R};
        false ->
            {V, P, L, delete(R, DeleteV)}
    end.

delete_or_swap({_, _, nil, nil})        -> {delete, nil};
delete_or_swap({_, _, GrandChild, nil}) -> {delete, GrandChild};
delete_or_swap({_, _, nil, GrandChild}) -> {delete, GrandChild};
delete_or_swap({DeleteV, DeleteP,
                L  = {LV, LP, LL, LR},
                R = {RV, RP, RL, RR}}) ->
    NewChild =
        case LV >= RV of
            true  -> {LV, LP, {DeleteV, DeleteP, LL, LR}, R};
            false -> {RV, RP, L, {DeleteV, DeleteP, RL, RR}}
        end,
    {swap, NewChild}.

rotation_required(_, nil)                -> no_rotate; %% root has no parent
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
