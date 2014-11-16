%%%----------------------------------------------------------------------------
%%% @author Gustav Simonsson <gustav.simonsson@gmail.com>
%%% @doc
%%% min-heap of integers using tuple as array-based approach
%%% http://en.wikipedia.org/wiki/Binary_heap
%%% http://www.cs.cmu.edu/~adamchik/15-121/lectures/Binary%20Heaps/heaps.html
%%% @end
%%% Created : 16 Nov 2014 by Gustav Simonsson <gustav.simonsson@gmail.com>
%%%----------------------------------------------------------------------------
-module(binary_heap).

-define(HEAP_CAPACITY, 1024 * 32).

-compile(export_all).

%%%============================================================================
%%% API
%%%============================================================================
test() ->
    {A,B,C} = now(),
    random:seed(A,B,C),
    test2(),
    test3(),
    test4(),
    ok.

find_min(BH) ->
    array:get(0, BH).

from_list(List) ->
    A = array:new(?HEAP_CAPACITY),
    lists:foldl(fun(E,Acc) ->
                        insert(Acc, E) end, A, List).

insert(BH, NewValue) ->
    I = array:sparse_size(BH),
    BH2 = array:set(I, NewValue, BH),
    %% "percolation up" - swap parent and child until
    %% parent is smaller than or equal to child
    percolate_up(BH2, I).

delete(BH) ->
    I = array:sparse_size(BH) - 1,
    J = 0,
    OldMin = array:get(J, BH),
    BH2 = array:set(J, array:get(I, BH), BH),
    {OldMin, percolate_down(BH2, 1)}.

%%%============================================================================
%%% Internal functions
%%%============================================================================
percolate_down(BH, Left) ->
    Right = Left + 1,
    LastIndex = array:sparse_size(BH) - 1,
    case Left < LastIndex of
        false ->
            BH;
        true ->
            SmallestChild =
                case (Right < LastIndex) and
                    (array:get(Right, BH) < array:get(Left, BH)) of
                    true  -> Right;
                    false -> Left
                end,
            ChildValue = array:get(SmallestChild, BH),
            ParentIndex = (SmallestChild - 1) div 2,
            ParentValue = array:get(ParentIndex, BH),
            case ChildValue < ParentValue of
                false ->
                    BH;
                true ->
                    BH2 = array:set(SmallestChild, ParentValue, BH),
                    BH3 = array:set(ParentIndex, ChildValue, BH2),
                    percolate_down(BH3, (SmallestChild * 2) + 1)
            end
    end.

%% Assumes a new element was just added at the end of array
percolate_up(BH, 0) -> BH;
percolate_up(BH, I) ->
    NewValue = array:get(I, BH),
    J = (I - 1) div 2,
    case NewValue =< (ParentValue = array:get(J, BH)) of
        true ->
            BH2 = array:set(I, ParentValue, BH),
            BH3 = array:set(J, NewValue, BH2),
            percolate_up(BH3, J);
        false ->
            BH
    end.

%%%============================================================================
%%% TESTS
%%%============================================================================
test1() ->
    %% Test values are from http://en.wikipedia.org/wiki/Binary_heap#Heap_operations
    TestList = [8, 4, 5, 11, 3],
    from_list(TestList).

test2() ->
    io:format("Test 2 generating random test list...~n", []),
    TestList =
        [random:uniform(?HEAP_CAPACITY) || _ <- lists:seq(1, ?HEAP_CAPACITY)],
    io:format("Test 2 Calling from_list/1~n", []),
    {Time, _Value} = timer:tc(fun() -> from_list(TestList) end),
    io:format("Test 2 OK: ~p microseconds~n", [Time]),
    ok.

test3() ->
    io:format("Test 3 generating random test list...~n", []),
    TestList =
        [random:uniform(?HEAP_CAPACITY) || _ <- lists:seq(1, ?HEAP_CAPACITY)],
    io:format("Test 3 Calling from_list/1 and then delete/1 ~n", []),
    {Time, _Value} =
        timer:tc(
          fun() ->
                  BinHeap = from_list(TestList),
                  lists:foldl(fun(_E, BH) -> {_, NBH} = delete(BH), NBH end,
                              BinHeap, TestList)
          end),
    io:format("Test 3 OK: ~p microseconds~n", [Time]),
    ok.

test4() ->
    ok.
