-module(treap).
-compile(export_all).

-define(MAX_SIZE, 1024).

%% treap:new().
new() ->
    {A,B,C} = now(),
    random:seed(A,B,C),
    %% {Value, Priority, Left, Right}
    {nil, nil, nil, nil}.

insert(Treap, Value) ->
    insert(Treap, Value, Treap).

insert({nil, _, _, _}, Value, _Parent) ->
    {Value, new_priority(), nil, nil};

insert({Value, Priority, nil, Right},
       NewValue,
       {ParentValue, ParentPriority, ParentLeft, ParentRight})
  when NewValue < Value ->
    {_, NewPriority, _, _} = New = new_node(NewValue),
    case ParentPriority =< Priority of
        true ->
            {Value, Priority, New, Right};
        false ->
            todo_left_rotation
    end;

insert({Value, Priority, Left, nil}, NewValue, Parent)
  when NewValue >= Value ->
    {Value, Priority, Left, new_node(NewValue)};

insert({Value, Priority, Left, Right} = Treap, NewValue, _Parent)
  when NewValue < Value ->
    {Value, Priority, insert(Left, NewValue, Treap), Right};

insert({Value, Priority, Left, Right} = Treap, NewValue, _Parent)
  when NewValue >= Value ->
    {Value, Priority, Left, insert(Right, NewValue, Treap)}.
    
new_priority() ->                
    random:uniform(?MAX_SIZE).

new_node(Value) ->
    {Value, new_priority(), nil, nil}.

%% T = treap:new().
%%
%%
%%
%%
%% 
